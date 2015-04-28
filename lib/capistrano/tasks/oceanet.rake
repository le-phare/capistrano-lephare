namespace :oceanet do
  namespace :php do
    desc 'Reload PHP server'
    task :reload do
      on roles(:web) do
        execute :sudo, "/srv/ot/scripts/manage_services.sh", "-s php", "-a reload"
      end
    end
  end
end
