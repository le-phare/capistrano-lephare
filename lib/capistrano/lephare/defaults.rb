# Librato username
set :librato_username,  false

# Librato token
set :librato_token,  false

# htpasswd user
set :htpasswd_user,  "admin.#{fetch(:application)}"

# htpasswd password
set :htpasswd_user,  "lephare"

set :htpasswd_whitelist, []
