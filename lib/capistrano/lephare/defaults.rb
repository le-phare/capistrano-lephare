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

# Tmp folder
set :tmp_dir, "/tmp/#{fetch(:stage)}"

# publish_assets
set :publish_assets, ENV["PUBLISH_ASSETS"] || false

# max db backups
set :keep_db_backups, 5

# database config file
set :database_config_file, -> { "#{fetch(:shared_path)}/app/config/parameters.yml" }

# Rollbar token
set :rollbar_token, false

set :mysqldump_args, "--opt --single-transaction"

set :db_pull_filename, "app/Resources/database/#{fetch(:stage)}.sql.bz2"

set :crontab_file, -> { "#{release_path}/app/Resources/crontab" }
