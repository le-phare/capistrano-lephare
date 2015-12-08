namespace :arpane do
    namespace :php do
        task :reload do
            on roles(:web) do
                execute "( touch #{shared_path}/restart_apache_to_clean_apc.txt && ( inotifywait --event delete --timeout 5 #{shared_path}/restart_apache_to_clean_apc.txt || [ $? -eq 1 ] ) )"
            end
        end
    end
end
