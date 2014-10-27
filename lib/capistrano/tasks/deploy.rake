namespace :deploy do

  desc 'Upload compiled assets'
  task :publish_assets do
    on roles(:web) do
      if fetch(:publish_assets)
        execute "rm -rf #{release_path}/web/compiled"
        upload! "web/compiled", "#{release_path}/web/", recursive: true
      end
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

      contents = <<-EOS.gsub(/^ {8}/, '')
        s~#AUTHORIZATION~AuthUserFile #{release_path}/web/.htpasswd \\
        AuthType Basic \\
        AuthName "#{fetch(:application)}" \\
        Require valid-user \\
        Order Allow,Deny \\
      EOS

      fetch(:htpasswd_whitelist).each do |ip|
        contents = "#{contents}Allow from #{ip} \\\n"
      end

      contents = "#{contents}Satisfy any~m"

      upload! StringIO.new(contents), shared_path.join("auth_basic.sed")

      execute "sed -i -f #{shared_path.join("auth_basic.sed")} #{release_path}/web/.htaccess"
    end
  end
end
