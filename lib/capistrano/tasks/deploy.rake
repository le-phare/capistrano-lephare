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

  desc "Secure the project with htpasswd."
  task :secure do
    on roles(:web) do
      execute "htpasswd -cb #{release_path}/web/.htpasswd #{fetch(:htpasswd_user)} #{fetch(:htpasswd_pwd)}"

      AUTHORIZATION = <<-EOS
        AuthUserFile #{release_path}/web/.htpasswd
        AuthType Basic
        AuthName "#{fetch(:application)}"
        Require valid-user
        Order Allow,Deny
        Allow from #{fetch(:htpasswd_whitelist).join(',')}
        Allow from env=NOPASSWD
        Satisfy any
      EOS

      execute "sed -i 's@\#AUTHORIZATION@#{AUTHORIZATION}@m' #{release_path}/web/.htaccess"
    end
  end
end
