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

# publish_assets
set :publish_assets, ENV["PUBLISH_ASSETS"] || false

# max db backups
set :keep_db_backups, 5

# database config file
set :database_config_file, -> { "#{fetch(:shared_path)}/app/config/parameters.yml" }

# Rollbar token
set :rollbar_token, false
