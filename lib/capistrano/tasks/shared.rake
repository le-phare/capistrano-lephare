#
# Manage shared files
#
# Configuration:
#
# - `shared_rsync_options`: Allow to specify which options to be used to pull rsync (default: `-avz --no-owner --no-group -delete`)
# - `shared_sync_pattern`:  Allow to filter directories path using regular expression (default: `/^(web\/medias|app\/Resources)/`)
#
namespace :shared do
  desc "Pull locally shared files using rsync"
  task :pull do
    on roles(:app) do |server|
      run_locally do
        rsync_options = fetch(:shared_rsync_options, "-avz --no-owner --no-group -delete")
        fetch(:linked_dirs).each do |dir|
          if dir =~ fetch(:shared_rsync_pattern, /^(web\/medias|app\/Resources)/)
            execute :rsync, rsync_options, "-e 'ssh -p #{fetch(:port, 22)}'", "#{server.user}@#{server.hostname}:#{shared_path}/#{dir}/*", "#{dir}"
          end
        end
      end
    end
  end
end
