# APC tasks
load File.expand_path("../tasks/apc.rake", __FILE__)

# Librato tasks
load File.expand_path("../tasks/librato.rake", __FILE__)

# Database tasks
load File.expand_path("../tasks/database.rake", __FILE__)

# Rollbar tasks
load File.expand_path("../tasks/rollbar.rake", __FILE__)

# Crontab tasks
load File.expand_path("../tasks/crontab.rake", __FILE__)

# Deploy tasks
load File.expand_path("../tasks/deploy.rake", __FILE__)

# SSH tasks
load File.expand_path("../tasks/ssh.rake", __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/lephare/defaults.rb"
  end
end
