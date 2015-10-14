desc "Open a ssh session on remote server"
task :ssh do
    on roles(:app) do |server|
        run_locally do
            exec "ssh -A #{server.user}@#{server} -t \"cd #{deploy_to}; bash --login\""
        end
    end
end
