# APC tasks
load File.expand_path("../tasks/apc.rake", __FILE__)

# Librato tasks
load File.expand_path("../tasks/librato.rake", __FILE__)

# Upload assets tasks
load File.expand_path("../tasks/upload.rake", __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/lephare/defaults.rb"
  end
end
