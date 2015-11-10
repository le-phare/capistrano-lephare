namespace :arpane do
    namespace :php do
        task :reload do
            on roles(:web) do
                execute "touch ~/restart_apache_to_clean_apc.txt"
            end
        end
    end
end
