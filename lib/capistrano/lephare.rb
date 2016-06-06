load File.expand_path("../tasks/apc.rake", __FILE__)
load File.expand_path("../tasks/arpane.rake", __FILE__)
load File.expand_path("../tasks/database.rake", __FILE__)
load File.expand_path("../tasks/mysql.rake", __FILE__)
load File.expand_path("../tasks/pgsql.rake", __FILE__)
load File.expand_path("../tasks/rollbar.rake", __FILE__)
load File.expand_path("../tasks/crontab.rake", __FILE__)
load File.expand_path("../tasks/deploy.rake", __FILE__)
load File.expand_path("../tasks/ssh.rake", __FILE__)
load File.expand_path("../tasks/oceanet.rake", __FILE__)
load File.expand_path("../tasks/opcache.rake", __FILE__)
#load File.expand_path("../tasks/log.rake", __FILE__)
load File.expand_path("../tasks/shared.rake", __FILE__)
load File.expand_path("../tasks/nvm.rake", __FILE__)
load File.expand_path("../tasks/npm.rake", __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/lephare/defaults.rb"
  end
end
