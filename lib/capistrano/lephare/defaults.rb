# APC sleep (in second)
set :apc_sleep, 5
set :apc_monitor_file, "/usr/share/doc/php-apc/apc.php"

# htpasswd user
set :htpasswd_user,  "admin.#{fetch(:application)}"

# htpasswd password
set :htpasswd_pwd,  "lephare"

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

# List of tables to exclude from the dump
set :dump_ignored_table_patterns, %w{__bkp_% __tmp_%}
set :dump_ignored_tables, %w{}

# Where to store the database backup
set :db_pull_filename, "app/Resources/database/#{fetch(:stage)}.sql.bz2"
set :dbms, :mysql

# Default crontab location
set :crontab_file, -> { "#{release_path}/app/Resources/crontab" }

# Assets path to synchronize
set :assets_path, %w{web/compiled}

# Maintenance page
set :maintenance_page_source, "app/Resources/views/Exception/503.html"
set :maintenance_page_name, "maintenance.html"

# Doctrine migration options
set :doctrine_migrations_options, "--allow-no-migration"

# Default Flow
after 'deploy:starting', 'composer:install_executable'
after 'deploy:publishing', 'deploy:migrate'
after 'deploy:finished', 'deploy:notify:finished'

# Apache version
set :apache_version, "2.2"
