namespace :deploy do

  desc 'Deploy with assets'
  task :with_assets do
    after 'deploy:publishing', 'deploy:publish_assets'
    invoke "deploy"
  end

  desc 'Upload compiled assets'
  task :publish_assets do
    on roles(:web) do
      info "Upload assets on server"

      fetch(:assets_path).each { |path|
        execute "rm -rf #{release_path}/#{path}"
        dirname = File.dirname(path)
        upload! path, "#{release_path}/#{dirname}", recursive: true
      }
    end
  end

  desc 'Launch doctrine migration'
  task :migrate do
    on roles(:db) do
      info "Migrate database"
      invoke 'symfony:console', 'doctrine:migrations:migrate', '--no-interaction'
    end
  end

  desc "Put a robots.txt that disallow all indexing."
  task :no_robots do
    on roles(:web) do
      info "Prevent robots indexation"
      execute "printf 'User-agent: *\\nDisallow: /' > #{release_path}/web/robots.txt"
    end
  end

  desc "Secure the project with htpasswd."
  task :secure do
    on roles(:web) do
      info "Secure the web access with a htpasswd"

      execute "htpasswd -cb #{release_path}/web/.htpasswd #{fetch(:htpasswd_user)} #{fetch(:htpasswd_pwd)}"

      contents = <<-EOS.gsub(/^ {8}/, '')
        s~#AUTHORIZATION~AuthUserFile #{release_path}/web/.htpasswd \\
        AuthType Basic \\
        AuthName "#{fetch(:application)}" \\
        Require valid-user \\
        Order Allow,Deny \\
        Allow from env=NOPASSWD \\
      EOS

      fetch(:htpasswd_whitelist).each do |ip|
        contents = "#{contents}Allow from #{ip} \\\n"
      end

      contents = "#{contents}Satisfy any~m"

      upload! StringIO.new(contents), shared_path.join("auth_basic.sed")

      execute "sed -i -f #{shared_path.join("auth_basic.sed")} #{release_path}/web/.htaccess"
    end
  end

  desc "Put a phpinfo.php in the root folder"
  task :phpinfo do
    on roles(:web) do
      phpinfo_file = "#{fetch(:webroot)}/phpinfo.php"
      contents = StringIO.new("<?php phpinfo(); ?>")
      upload! contents, phpinfo_file
    end
  end

  namespace :web do
    desc "Copy the maintenance page in the documentRoot"
    task :disabled do
      on roles(:web) do
        execute "cp #{fetch(:maintenance_page_source)} #{fetch(:webroot)}/#{fetch(:maintenance_page_name)}"
      end
    end

    desc "Remove the maintenance page"
    task :enabled do
      on roles(:web) do
        execute "rm -rf #{fetch(:webroot)}/#{fetch(:maintenance_page_name)}"
      end
    end
  end

end
