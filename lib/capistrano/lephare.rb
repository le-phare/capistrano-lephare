load File.expand_path("../tasks/apc.rake", __FILE__)
load File.expand_path("../tasks/database.rake", __FILE__)
load File.expand_path("../tasks/rollbar.rake", __FILE__)
load File.expand_path("../tasks/crontab.rake", __FILE__)
load File.expand_path("../tasks/deploy.rake", __FILE__)
load File.expand_path("../tasks/ssh.rake", __FILE__)
load File.expand_path("../tasks/oceanet.rake", __FILE__)
load File.expand_path("../tasks/log.rake", __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/lephare/defaults.rb"
  end
end
