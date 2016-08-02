namespace :opcache do
  namespace :cache do
    desc <<-DESC
      Create a temporary PHP file to clear OPCache, call it (using curl) and removes it
      This task must be triggered AFTER the deployment.
    DESC
    task :clear do
      invoke "#{scm}:set_current_revision"
      on roles(:web), in: :parallel do |server|
        apc_file = "#{fetch(:webroot)}/opcache_clear_#{fetch(:current_revision)}.php"
        contents = StringIO.new("<?php if (function_exists('apc_clear_cache')) { apc_clear_cache(); apc_clear_cache('user'); } opcache_reset(); clearstatcache(true); echo trim(file_get_contents(__DIR__.'/../REVISION')); ?>")
        upload! contents, apc_file

        run_locally do
          if not "#{server.properties.domain}".match(/:\/\//)
            domain = "http://#{server.properties.domain}"
          end

          output = capture(:curl, '-s', '-l', "#{domain}/opcache_clear_#{fetch(:current_revision)}.php")
          sleep = fetch(:apc_sleep)

          while output != fetch(:current_revision)
            sleep(sleep)
            output = capture(:curl, '-s', '-l', "#{domain}/opcache_clear_#{fetch(:current_revision)}.php")

            debug "Retry OPCache clear in #{sleep} second."
          end

          info 'Successfully cleared OPCache cache.'
        end

        execute "rm #{apc_file}"
      end
    end
  end

  namespace :monitor do
    desc "Enable OPCache monitoring"
    task :enable do
      on roles(:web) do
        execute :cp, "#{fetch(:webroot)}/../vendor/rlerdorf/opcache-status/opcache.php", "#{fetch(:webroot)}/"
      end
    end

    desc "Disable OPCache monitoring"
    task :disable do
      on roles(:web) do
        execute :rm, "#{fetch(:webroot)}/opcache.php"
      end
    end
  end
end
