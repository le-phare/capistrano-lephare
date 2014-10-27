namespace :deploy do

  desc 'Upload compiled assets'
  task :publish_assets do
    on roles(:web) do
      execute "rm -rf #{release_path}/web/compiled"
      upload! "web/compiled", "#{release_path}/web/", recursive: true
    end
  end

  desc 'Launch doctrine migration'
  task :migrate do
    on roles(:web) do
      invoke 'symfony:console', 'doctrine:migrations:migrate', '--no-interaction'
    end
  end

  desc "Put a robots.txt that disallow all indexing."
  task :no_robots do
    on roles(:web) do
      execute "printf 'User-agent: *\\nDisallow: /' > #{release_path}/web/robots.txt"
    end
  end
end
