namespace :pgsql do

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
                    where.push("tablename like '#{pattern}'")
                }
                tables = []
                output = capture(
                    "PGPASSWORD=#{password}",
                    :psql,
                    "-A -U #{username} #{hostcmd} -d #{database}",
                    "-c \"SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname ='public' AND #{where.join(' OR ')} ORDER BY tablename \"",
                    " | sed '1d;$d'"
                )

                output.each_line { |line|
                    tables.push(line.strip)
                }
            else
                tables = fetch(:dump_ignored_tables)
            end

            ignored_table = ""
            tables.each { |table|
                ignored_table = "#{ignored_table} -T #{database}.#{table}"
            }

            execute(
                "PGPASSWORD=#{password}",
                :pg_dump,
                "-Fc",
                "-U #{username} #{hostcmd} -d #{database}",
                "#{fetch(:pgdump_args)} #{ignored_table}",
                " > #{backup_path}/#{filename}"
            )

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
            pwdcmd = password.nil? ? '' : "PGPASSWORD=#{password} "

            execute(
                "#{pwdcmd}",
                :dropdb,
                "-U '#{username}'",
                "#{hostcmd}",
                "--if-exists",
                "'#{database}'"
            )

            execute(
                "#{pwdcmd}",
                :pg_restore,
                "-U '#{username}'",
                "#{hostcmd}",
                "-d #{database}",
                "-c -C -j 8 --no-owner -n public",
                "#{fetch(:db_pull_filename)}"
            )
        end
    end
end
