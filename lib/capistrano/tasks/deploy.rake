namespace :deploy do

  desc 'Deploy with assets'
  task :with_assets do
    after 'deploy:updated', 'deploy:publish_assets'
    invoke "deploy"
  end

  desc 'Upload compiled assets'
  task :publish_assets do
    on roles(:web) do |remote|
      info "Upload assets on server"

      ssh_options = fetch(:ssh_options)
      proxy = ssh_options[:proxy] != nil ? "-o ProxyCommand='#{ssh_options[:proxy].inspect}'" : nil
      remote.port ||= 22

      fetch(:assets_path).each do |path|
        run_locally do
          execute :rsync, "-avz --delete", "-e \"ssh #{proxy} -p #{remote.port}\"", "#{path}/", "#{remote.user}@#{remote.hostname}:#{release_path}/#{path}/"
        end
      end
    end
  end

  desc "Put a robots.txt that disallow all indexing."
  task :no_robots do
    on roles(:web) do
      info "Prevent robots indexation"
      execute "printf 'User-agent: *\\nDisallow: /\\nUser-agent: LinkChecker\\nAllow:/' > #{release_path}/web/robots.txt"
    end
  end

  desc "Secure the project with htpasswd."
  task :secure do
    on roles(:web) do
      info "Secure the web access with a htpasswd"

      execute "htpasswd -cb #{shared_path}/.htpasswd #{fetch(:htpasswd_user)} #{fetch(:htpasswd_pwd)}"

      if (fetch(:apache_version) == "2.4")
        contents = <<-EOS.gsub(/^ {8}/, '')
          s~#AUTHORIZATION~<RequireAny> \\
              <RequireAll> \\
                Require env NOPASSWD \\
                Require all granted \\
              </RequireAll> \\
              <RequireAll> \\
                 AuthUserFile #{shared_path}/.htpasswd \\
                 AuthType Basic \\
                 AuthName "#{fetch(:application)}" \\
                 Require valid-user \\
              </RequireAll> \\
        EOS

        fetch(:htpasswd_whitelist).each do |ip|
          contents = "#{contents}    Require ip #{ip} \\\n"
        end

        contents = "#{contents}</RequireAny>~m"
      else
        contents = <<-EOS.gsub(/^ {8}/, '')
          s~#AUTHORIZATION~AuthUserFile #{shared_path}/.htpasswd \\
          AuthType Basic \\
          AuthName "#{fetch(:application)}" \\
          Require valid-user \\
          Order Deny,Allow \\
          Satisfy any \\
          Deny from all \\
          Allow from env=NOPASSWD \\
        EOS

        fetch(:htpasswd_whitelist).each do |ip|
          contents = "#{contents}Allow from #{ip} \\\n"
        end
        contents = "#{contents}~m"
      end

      upload! StringIO.new(contents), shared_path.join("auth_basic.sed")

      execute "sed -i -f #{shared_path.join("auth_basic.sed")} #{fetch(:webroot)}/.htaccess"
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
    task :disable do
      on roles(:web) do
        execute "cp #{release_path}/#{fetch(:maintenance_page_source)} #{fetch(:webroot)}/#{fetch(:maintenance_page_name)}"
      end
    end

    desc "Remove the maintenance page"
    task :enable do
      on roles(:web) do
        execute "rm -rf #{fetch(:webroot)}/#{fetch(:maintenance_page_name)}"
      end
    end
  end

  namespace :notify do
    desc "Notify the end of the deployement"
    task :finished do
      run_locally do
        if test("which notify-send")
            execute "notify-send", "'#{fetch(:application)}'", "'Deploy finished on #{fetch(:stage)}'"
        end
      end
    end
  end

  namespace :doctrine do

    desc 'Launch doctrine migration'
    task :migrate do
      on roles(:db) do
        info "Migrate database"
        invoke 'symfony:console', 'doctrine:migrations:migrate', "--no-interaction #{fetch(:doctrine_migrations_options)}"
      end
    end

    desc 'Clear doctrine cache'
    task :clear_cache do
      on roles(:db) do
        info "Clear doctrine cache"
        invoke 'symfony:console', 'doctrine:cache:clear-metadata'
        invoke 'symfony:console', 'doctrine:cache:clear-query'
        invoke 'symfony:console', 'doctrine:cache:clear-result'
      end
    end
  end

  namespace :check do
    desc "touch linked files before symlinking"
    task :touch_linked_files do
      on roles(:app) do
        execute :touch, fetch(:linked_files).map { |f| "#{shared_path}/#{f}" }.join(" ")
      end
    end
  end

end

namespace :load do
  task :defaults do
    before "deploy:check:linked_files", "deploy:check:touch_linked_files"
  end
end
