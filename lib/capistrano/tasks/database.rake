desc "Backup the database"
namespace :db do
    task :backup do
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            execute :mkdir, "-p #{backup_path}"
            basename = 'database'

            username, password, database, host = get_remote_database_config()

            filename = "#{basename}_#{fetch(:stage)}_#{database}_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.bz2"

            hostcmd = host.nil? ? '' : "-h #{host}"
            execute :mysqldump, "-u #{username} --password='#{password}' --databases #{database} #{hostcmd} | bzip2 -9 > #{backup_path}/#{filename}"
            purge_old_backups "#{basename}", "#{backup_path}"

            latest = "#{backup_path}/#{basename}_#{fetch(:stage)}_#{database}_latest.sql.bz2"
            if test("[ -f #{latest} ]")
                execute "rm #{latest}"
            end
            execute "ln -s #{backup_path}/#{filename} #{latest}"
        end
    end

    task :pull do
        invoke "db:backup"
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            username, password, database, host = get_remote_database_config()
            latest = "#{backup_path}/database_#{fetch(:stage)}_#{database}_latest.sql.bz2"
            download! latest, "backups/database_#{fetch(:stage)}_latest.sql.bz2"

            run_locally do
                username, password, database, host = get_local_database_config()
                hostcmd = host.nil? ? '' : "-h #{host}"
                execute :bunzip2, "< backups/database_#{fetch(:stage)}_latest.sql.bz2 | ", :mysql, "-u '#{username}' --password='#{password}' #{hostcmd} #{database}"
            end
        end
    end

    def get_remote_database_config()
        remote_config = capture("cat #{shared_path}/app/config/parameters.yml")
        config = YAML::load(remote_config)
        return config['parameters']['database_user'],
            config['parameters']['database_password'],
            config['parameters']['database_name'],
            config['parameters']['database_host']
    end

    def get_local_database_config()
        run_locally do
            config = capture("cat app/config/parameters.yml")
            config = YAML::load(config)
            return config['parameters']['database_user'],
                config['parameters']['database_password'],
                config['parameters']['database_name'],
                config['parameters']['database_host']
        end
    end


    def purge_old_backups(basename,backup_path)
        max_keep = fetch(:keep_db_backups, 5).to_i
        backup_files = capture("ls -t #{backup_path}/#{basename}*").split.reverse
        if max_keep >= backup_files.length
            info "No old database backups to clean up"
        else
            info "Keeping #{max_keep} of #{backup_files.length} database backups"
            delete_backups = (backup_files - backup_files.last(max_keep)).join(" ")
            execute :rm, "-rf #{delete_backups}"
        end
    end
end
