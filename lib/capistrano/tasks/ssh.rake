desc "Open a ssh session on remote server"
task :ssh do
    on roles(:app) do |server|
        server.port ||= 22
        #ssh_options = fetch(:ssh_options)
        proxy = ssh_options[:proxy] != nil ? "-o ProxyCommand='#{ssh_options[:proxy].inspect}'" : nil

        run_locally do
            exec "ssh -A #{server.user}@#{server} -p #{server.port} -t \"cd #{deploy_to}; bash --login\""
        end
    end
end
