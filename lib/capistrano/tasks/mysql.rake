namespace :mysql do

    desc "Backup the database"
    task :backup do
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            execute :mkdir, "-p #{backup_path}"

            basename = 'database'
            username, password, database, host = get_remote_database_config()
            filename = "#{basename}_#{fetch(:stage)}_#{database}_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.bz2"
            hostcmd = host.nil? ? '' : "-h #{host}"

            if fetch(:dump_ignored_table_patterns)
                where = []
                fetch(:dump_ignored_table_patterns).each { |pattern|
                    where.push("Tables_in_#{database} like '#{pattern}'")
                }
                tables = []
                output = capture(:mysql, "-u #{username} --password='#{password}' #{hostcmd} -D #{database} -Bse \"show tables where #{where.join(' OR ')}\"")
                output.each_line { |line|
                    tables.push(line.strip)
                }
            else
                tables = fetch(:dump_ignored_tables)
            end

            ignored_table = ""
            tables.each { |table|
                ignored_table = "#{ignored_table} --ignore-table #{database}.#{table}"
            }

            execute :mysqldump, "#{fetch(:mysqldump_args)} #{ignored_table} -u #{username} --password='#{password}' #{hostcmd} #{database} | bzip2 -9 > #{backup_path}/#{filename}"
            purge_old_backups "#{basename}", "#{backup_path}"

            latest = "#{backup_path}/#{basename}_#{fetch(:stage)}_#{database}_latest.sql.bz2"
            if test("[ -f #{latest} ]")
                execute "rm #{latest}"
            end
            execute "ln -s #{backup_path}/#{filename} #{latest}"
        end
    end

    task :load_local do
        run_locally do
            username, password, database, host = get_local_database_config()
            hostcmd = host.nil? ? '' : "-h #{host}"
            execute :mysql, "-u '#{username}' --password='#{password}' #{hostcmd}  -e 'DROP DATABASE IF EXISTS #{database}' &> /dev/null"
            execute :mysql, "-u '#{username}' --password='#{password}' #{hostcmd} -e 'CREATE DATABASE #{database} COLLATE utf8_unicode_ci'"
            execute :bzcat, " #{fetch(:db_pull_filename)} | ", :mysql, "-u '#{username}' --password='#{password}' #{hostcmd} #{database}"
        end
    end
end
