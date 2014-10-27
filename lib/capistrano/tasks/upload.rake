namespace :deploy do
  namespace :upload do
    desc 'Upload compiled assets'
    task :assets do
      on roles(:web) do
        execute "rm -rf #{release_path}/web/compiled"
        upload! "web/compiled", "#{release_path}/web/", recursive: true
      end
    end
  end
end
