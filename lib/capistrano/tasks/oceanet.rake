namespace :oceanet do
  namespace :php do
    desc 'Reload PHP server'
    task :reload do
      on roles(:web) do
        execute :sudo, "/srv/ot/scripts/manage_services.sh", "-s php", "-a reload"
      end
    end
  end

  namespace :log do
    desc 'Connect as user authorized to browse logs in /var/logs/'
    task :browse do
      on roles(:app) do |server|
        run_locally do
            exec "ssh adminlephare@#{server}"
        end
      end
    end
  end

  namespace :letsencrypt do
    desc 'Add the .well-known'
    task :symlink do
      on roles(:web) do |server|
        execute "ln -s #{fetch(:letsencrypt_well_known_path)} #{fetch(:webroot)}/.well-known"
      end
    end
  end
end
