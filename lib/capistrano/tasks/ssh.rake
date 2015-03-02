desc "Open a ssh session on remote server"
task :ssh do
    on roles(:app) do |server|
        run_locally do
            exec "ssh #{server.user}@#{server}"
        end
    end
end
