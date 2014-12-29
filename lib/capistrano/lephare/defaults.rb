# APC sleep (in second)
set :apc_sleep, 5
set :apc_monitor_file, "/usr/share/doc/php-apc/apc.php"

# Librato username
set :librato_username,  false

# Librato token
set :librato_token,  false

# htpasswd user
set :htpasswd_user,  "admin.#{fetch(:application)}"

# htpasswd password
set :htpasswd_user,  "lephare"

# htpasswd whitelist
set :htpasswd_whitelist, []

# Webroot
set :webroot, -> { "#{release_path}/web" }

# Tmp folder
set :tmp_dir, "/tmp/#{fetch(:stage)}"

# max db backups
set :keep_db_backups, 5

# database config file
set :database_config_file, -> { "#{fetch(:shared_path)}/app/config/parameters.yml" }

# Rollbar token
set :rollbar_token, false

# Mysqldump arguments
set :mysqldump_args, "--opt --single-transaction"

# Where to store the database backup
set :db_pull_filename, "app/Resources/database/#{fetch(:stage)}.sql.bz2"

# Default crontab location
set :crontab_file, -> { "#{release_path}/app/Resources/crontab" }

# Assets path to synchronize
set :assets_path, %w{web/compiled}

# Default Flow
after 'deploy:starting', 'composer:install_executable'
after 'deploy:publishing', 'symfony:assets:install'
after 'deploy:finishing', 'deploy:migrate'
after 'deploy:finished', 'deploy:cleanup'
