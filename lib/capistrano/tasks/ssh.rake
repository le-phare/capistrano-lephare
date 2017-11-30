desc "Open a ssh session on remote server"
task :ssh do
    on roles(:app) do |server|
        server.port ||= 22
        ssh_options = fetch(:ssh_options)
        proxy = ssh_options[:proxy] != nil ? "-o ProxyCommand='#{ssh_options[:proxy].inspect}'" : nil

        run_locally do
            exec "ssh #{proxy} -A #{server.user}@#{server} -p #{server.port} -t \"cd #{deploy_to}; bash --login\""
        end
    end
end

namespace :load do
    task :defaults do
        require 'net/ssh/proxy/command'
        set :ssh_options, -> {
            ssh_gateway = fetch(:ssh_gateway, "localhost")
            return {
              proxy: Net::SSH::Proxy::Command.new("ssh #{ssh_gateway} -W %h:%p")
            }
        }
    end
end
