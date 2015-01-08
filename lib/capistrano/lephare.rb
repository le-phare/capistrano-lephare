# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('./tasks/*.rake').each { |r| load r }

namespace :load do
  task :defaults do
    load "capistrano/lephare/defaults.rb"
  end
end
