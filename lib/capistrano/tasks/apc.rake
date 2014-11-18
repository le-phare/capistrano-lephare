namespace :apc do
  namespace :cache do
    desc <<-DESC
      Create a temporary PHP file to clear APC cache, call it (using curl) and removes it
      This task must be triggered AFTER the deployment to clear APC cache
    DESC
    task :clear do
      invoke "#{scm}:set_current_revision"
      on roles(:web) do
        apc_file = "#{release_path}/web/apc_clear.php"
        contents = StringIO.new("<?php apc_clear_cache(); apc_clear_cache('user'); apc_clear_cache('opcode'); clearstatcache(true); echo trim(file_get_contents(__DIR__.'/../REVISION')); ?>")
        upload! contents, apc_file

        run_locally do
          output = %x[curl -s -l http://#{fetch(:domain)}/apc_clear.php]

          while output != fetch(:current_revision)
            sleep(1)
            output = %x[curl -s -l http://#{fetch(:domain)}/apc_clear.php]
          end
        done

        execute "rm #{apc_file}"
      end
    end
  end

  namespace :monitor do
    desc "Enable the APC web-gui monitor."
    task :enable do
      on roles(:web) do
        apc_file = "/usr/share/doc/php-apc/apc.php"
        execute "cp #{apc_file} #{release_path}/web/"
      end
    end

    desc "Disable the APC web-gui monitor."
    task :disable do
      on roles(:web) do
        execute "rm #{release_path}/web/apc.php"
      end
    end
  end
end
