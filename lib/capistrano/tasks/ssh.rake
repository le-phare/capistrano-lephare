desc "Open a ssh session on remote server"
task :ssh do
    on roles(:app) do |server|
        server.port ||= 22
        run_locally do
            exec "ssh -A #{server.user}@#{server} -p #{server.port} -t \"cd #{deploy_to}; bash --login\""
        end
    end
end
