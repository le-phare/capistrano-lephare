namespace :oceanet do
  namespace :php do
    desc "Reload PHP"
    task :reload do
      on roles(:web) do
        info 'Reload PHP'
        execute "echo 'reload' > /tmp/clearcache"
      end
    end
  end
end
