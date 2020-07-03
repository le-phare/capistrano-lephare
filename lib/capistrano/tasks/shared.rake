#
# Manage shared files
#
# Configuration:
#
# - `shared_rsync_options`:    Allow to specify which options to be used to pull rsync (default: `-avzz --no-owner --no-group -delete`)
# - `shared_sync_pattern`:     Allow to filter directories path using regular expression (default: `/^(web\/medias|app\/Resources)/`)
# - `shared_exclude_paths`:    Allow to exclude paths using rsync exclude patterns (default: %w{.tmb/ .gitkeep .DS_Store Thumbs.db})
#
namespace :shared do
  desc "Pull locally shared files using rsync"
  task :pull do
    on roles(:app) do |server|
      run_locally do
        rsync_options = fetch(:shared_rsync_options, "-avzz --no-owner --no-group --delete")
        shared_exclude_paths = fetch(:shared_exclude_paths, %w{.tmb/ .gitkeep .DS_Store Thumbs.db})
        rsync_exclude = shared_exclude_paths.map { |f| "--exclude \"#{f}\"" }.join(" ")
        ssh_options = fetch(:ssh_options)
        proxy = ssh_options[:proxy] != nil ? "-o ProxyCommand='#{ssh_options[:proxy].inspect}'" : nil
        server.port ||= 22
        fetch(:linked_dirs).each do |dir|
          if dir =~ fetch(:shared_rsync_pattern, /^(web\/medias|app\/Resources)/) and not shared_exclude_paths.include?(dir)
            execute :rsync, rsync_options, rsync_exclude, "-e \"ssh #{proxy} -p #{server.port}\"", "#{server.user}@#{server.hostname}:#{shared_path}/#{dir}/", "#{dir}/"
          end
        end
      end
    end
  end
end
