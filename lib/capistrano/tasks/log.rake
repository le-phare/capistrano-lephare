set :startDate, -> { DateTime.now.strftime(format="%H:%M:%S") }
set :finishdate, -> { DateTime.now.strftime(format="%H:%M:%S") }

after 'deploy:failed', :send_for_help do
  SSHKit.config.output.error "Deploy stopped"
end

before('deploy:starting', :log_before_deploy_starting) do
  SSHKit.config.output.info "\bStarting deploy on #{fetch(:stage)} at #{fetch(:startDate)}".yellow
end

before('deploy:updating', :log_before_deploy_updating) do
  SSHKit.config.output.info  "\bUpdating".yellow
  SSHKit.config.output.start "  ├── Updating code & creating release"
end

before('composer:install', :log_before_composer_install) do
  SSHKit.config.output.start("  ├── Composer install")
end
after('composer:install', :log_after_composer_install) do
  SSHKit.config.output.success
end

before('deploy:publish_assets', :log_before_publish_assets) do
  SSHKit.config.output.start("  ├── Uploading assets")
end
after('deploy:publish_assets', :log_after_publish_assets) do
  SSHKit.config.output.success
end

before('symfony:cache:warmup', :log_before_cache_warmup) do
  SSHKit.config.output.start("  ├── Warmup symfony cache")
end
after('symfony:cache:warmup', :log_after_cache_warmup) do
  SSHKit.config.output.success
end

before('symfony:clear_controllers', :log_before_clear_controlle) do
  SSHKit.config.output.start("  ├── Clear symfony controllers")
end
after('symfony:clear_controllers', :log_after_clear_controlle) do
  SSHKit.config.output.success
end

before('deploy:publishing', :log_before_deploy_publishing) do
  SSHKit.config.output.info "\bPublishing".yellow
end

before('deploy:symlink:release', :log_before_symlink_release) do
  SSHKit.config.output.start "  ├── Symlinking release"
end
after('deploy:symlink:release', :log_after_symlink_release) do
  SSHKit.config.output.success
end

before('deploy:migrate', :log_before_deploy_migrate) do
  SSHKit.config.output.start("  ├── Migrate database")
end
after('deploy:migrate', :log_after_deploy_migrate) do
  SSHKit.config.output.success
end

before('deploy:cleanup', :log_before_deploy_cleanup) do
  SSHKit.config.output.start("  ├── Cleanup releases")
end
after('deploy:cleanup', :log_after_deploy_cleanup) do
  SSHKit.config.output.success
end

before('rollbar:notify', :log_before_rollbar_notify) do
  SSHKit.config.output.start("  ├── Notify Rollbar")
end
after('rollbar:notify', :log_after_rollbar_notify) do
  SSHKit.config.output.success
end

before('oceanet:php:reload', :log_before_php_reload) do
  SSHKit.config.output.start("  ├── Reload PHP server")
end
after('oceanet:php:reload', :log_after_php_reload) do
  SSHKit.config.output.success
end

before('crontab:update', :log_before_crontab_update) do
  SSHKit.config.output.start("  ├── Update crontab")
end
after('crontab:update', :log_after_pcrontab_update) do
  SSHKit.config.output.success
end

before('deploy:no_robots', :log_before_no_robot) do
  SSHKit.config.output.start("  ├── Prevent indexation with robots.txt")
end
after('deploy:no_robots', :log_after_no_robot) do
  SSHKit.config.output.success
end

before('deploy:secure', :log_before_secure) do
  SSHKit.config.output.start("  ├── Secure with htpasswd")
end
after('deploy:secure', :log_after_secure) do
  SSHKit.config.output.success
end

before('deploy:secure', :log_before_secure) do
  SSHKit.config.output.start("  ├── Secure with htpasswd")
end
after('deploy:secure', :log_after_secure) do
  SSHKit.config.output.success
end

before('deploy:copy_files', :log_before_copy_files) do
  SSHKit.config.output.success
  SSHKit.config.output.start("  ├── Copying files from previous release")
end
after('deploy:copy_files', :log_after_copy_files) do
  SSHKit.config.output.success
end

before('deploy:finishing', :log_before_deploy_finishing) do
  SSHKit.config.output.info "\bFinishing release".yellow
end

after('deploy:finished', :log_after_deploy_finished) do
  SSHKit.config.output.info "\bDeploy finished at #{fetch(:finishdate)}".yellow
end

before('mysql:pull', :log_before_mysql_pull) do
  SSHKit.config.output.info "Pulling #{fetch(:stage)} database".yellow
end
before('mysql:pull', :log_before_mysql_backup) do
  SSHKit.config.output.start("  ├── Backup remote database")
end
after('mysql:backup', :log_after_mysql_backup) do
  SSHKit.config.output.success
end
before('mysql:download', :log_before_mysql_download) do
  SSHKit.config.output.start "  ├── Downloading remote database"
end
after('mysql:download', :log_after_mysql_download) do
  SSHKit.config.output.success
end
before('mysql:load_local', :log_before_load_local) do
  SSHKit.config.output.start "  ├── Drop, create and load local database"
end
after('mysql:load_local', :log_after_load_local) do
  SSHKit.config.output.success
end

before('apc:cache:clear', :log_before_apc_cache_clear) do
  SSHKit.config.output.start("  ├── Clear APC")
end
after('apc:cache:clear', :log_after_apc_cache_clear) do
  SSHKit.config.output.success
end
