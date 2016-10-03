namespace :apc do
  namespace :cache do
    desc <<-DESC
      Create a temporary PHP file to clear APC cache, call it (using curl) and removes it
      This task must be triggered AFTER the deployment to clear APC cache
    DESC
    task :clear do
      invoke "#{scm}:set_current_revision"
      on roles(:web), in: :parallel do |server|
        apc_file = "#{fetch(:webroot)}/apc_clear_#{fetch(:current_revision)}.php"
        contents = StringIO.new("<?php apc_clear_cache(); apc_clear_cache('user'); apc_clear_cache('opcode'); clearstatcache(true); echo trim(file_get_contents(__DIR__.'/../REVISION')); ?>")
        upload! contents, apc_file

        run_locally do
          if not "#{server.properties.domain}".match(/:\/\//)
            domain = "http://#{server.properties.domain}"
          else
            domain = server.properties.domain
          end

          output = %x[curl -s -l #{domain}/apc_clear_#{fetch(:current_revision)}.php]
          sleep = fetch(:apc_sleep)

          while output != fetch(:current_revision)
            sleep(sleep)
            output = %x[curl -s -l #{domain}/apc_clear_#{fetch(:current_revision)}.php]

            debug "Retry APC clear in #{sleep} second."
          end

          info 'Successfully cleared APC cache.'
        end

        execute "rm #{apc_file}"
      end
    end
  end

  namespace :monitor do
    desc "Enable the APC web-gui monitor."
    task :enable do
      on roles(:web) do
        execute "cp #{fetch(:apc_monitor_file)} #{fetch(:webroot)}"
      end
    end

    desc "Disable the APC web-gui monitor."
    task :disable do
      on roles(:web) do
        basename = File.basename(fetch(:apc_monitor_file))
        execute "rm #{fetch(:webroot)}/#{basename}"
      end
    end
  end
end
