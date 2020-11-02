namespace :mysql do

    desc "Backup the database"
    task :backup do
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            execute :mkdir, "-p #{backup_path}"

            basename = 'database'
            username, password, database, host = get_remote_database_config()
            filename = "#{basename}_#{fetch(:stage)}_#{database}_data_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.bz2"
            hostcmd = host.nil? ? '' : "-h #{host}"

            if fetch(:dump_ignored_table_patterns)
                where = []
                fetch(:dump_ignored_table_patterns).each { |pattern|
                    where.push("\`Tables_in_#{database}\` like \"#{pattern}\"")
                }
                tables = []
                output = capture(:mysql, "-u #{username} --password='#{password}' #{hostcmd} -D #{database} -Bse \'show tables where #{where.join(' OR ')}\'")
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

    task :download do
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            username, password, database, host = get_remote_database_config()
            latest = "#{backup_path}/database_#{fetch(:stage)}_#{database}_latest.sql.bz2"
            download! latest, "#{fetch(:db_pull_filename)}"
        end
    end

    task :load_local do
        run_locally do
            username, password, database, host, port, server_version = get_local_database_config()
            hostcmd = host.nil? ? "" : "-h #{host}"
            portcmd = port.nil? ? "" : "-P #{port}"
            server_version = server_version.nil? ? "latest": server_version

            execute(
                "docker",
                "run",
                "--net dev_database",
                "--rm",
                "mysql:#{server_version}",
                "mysql",
                "-u '#{username}' --password='#{password}' #{hostcmd} #{portcmd}  -e 'DROP DATABASE IF EXISTS `#{database}`'",
                raise_on_non_zero_exit: false
            )
            execute(
                "docker",
                "run",
                "--net dev_database",
                "--rm",
                "mysql:#{server_version}",
                "mysql",
                "-u '#{username}' --password='#{password}' #{hostcmd} #{portcmd}  -e 'CREATE DATABASE `#{database}` COLLATE utf8_unicode_ci'"
            )
            execute("bzip2 -dkc #{fetch(:db_pull_filename)} > load_local.tmp.sql")
            execute(
                "docker",
                "run",
                "--net dev_database",
                "-v $(pwd)/load_local.tmp.sql:/load_local.tmp.sql",
                "--rm",
                "mysql:#{server_version}",
                "sh -c \"cat /load_local.tmp.sql |  mysql -u '#{username}' --password='#{password}' #{hostcmd} #{portcmd} #{database}\""
            )
            execute("rm load_local.tmp.sql")
        end
    end
end
