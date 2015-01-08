namespace :ssh do
    desc "Open a ssh session on remote server"
    task :open do
        on roles(:app) do |server|
            run_locally do
                exec "ssh #{server.user}@#{server}"
            end
        end
    end
end
