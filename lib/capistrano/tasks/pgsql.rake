namespace :pgsql do
    namespace :backup do
        desc "Backup the database"
        task :data do
            on roles(:db) do |host|
                backup_path = "#{fetch(:deploy_to)}/backups"
                execute :mkdir, "-p #{backup_path}"

                basename = 'database'
                username, password, database, host = get_remote_database_config()
                filename = "#{basename}_#{fetch(:stage)}_#{database}_data_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.dump"
                hostcmd = host.nil? ? '' : "-h #{host}"

                if fetch(:dump_ignored_table_patterns)
                    where = []
                    fetch(:dump_ignored_table_patterns).each { |pattern|
                        where.push("tablename like '#{pattern}'")
                    }
                    tables = []
                    output = capture(
                        "PGPASSWORD='#{password}'",
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
                    "PGPASSWORD='#{password}'",
                    :pg_dump,
                    "-Fc",
                    "-a -n public",
                    "-U #{username} #{hostcmd} -d #{database}",
                    "#{fetch(:pgdump_args)} #{ignored_table}",
                    " > #{backup_path}/#{filename}"
                )

                purge_old_backups "#{basename}", "#{backup_path}"

                latest = "#{backup_path}/#{basename}_#{fetch(:stage)}_#{database}_data_latest.dump"
                if test("[ -f #{latest} ]")
                    execute "rm #{latest}"
                end
                execute "ln -s #{backup_path}/#{filename} #{latest}"
            end
        end

        desc "Backup the database"
        task :schema do
            on roles(:db) do |host|
                backup_path = "#{fetch(:deploy_to)}/backups"
                execute :mkdir, "-p #{backup_path}"

                basename = 'database'
                username, password, database, host = get_remote_database_config()
                filename = "#{basename}_#{fetch(:stage)}_#{database}_schema_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.dump"
                hostcmd = host.nil? ? '' : "-h #{host}"


                execute(
                    "PGPASSWORD='#{password}'",
                    :pg_dump,
                    "-Fc",
                    "-s",
                    "-U #{username} #{hostcmd} -d #{database}",
                    " > #{backup_path}/#{filename}"
                )

                purge_old_backups "#{basename}", "#{backup_path}"

                latest = "#{backup_path}/#{basename}_#{fetch(:stage)}_#{database}_schema_latest.dump"
                if test("[ -f #{latest} ]")
                    execute "rm #{latest}"
                end
                execute "ln -s #{backup_path}/#{filename} #{latest}"
            end
        end
    end

    task :download do
        on roles(:db) do |host|
            backup_path = "#{fetch(:deploy_to)}/backups"
            username, password, database, host = get_remote_database_config()

            run_locally do
                execute :mkdir, "-p #{fetch(:db_pull_dir)}"
            end

            latest = "#{backup_path}/database_#{fetch(:stage)}_#{database}_data_latest.dump"
            download! latest, "#{fetch(:db_pull_dir)}/#{fetch(:stage)}_data.dump"

            latest = "#{backup_path}/database_#{fetch(:stage)}_#{database}_schema_latest.dump"
            download! latest, "#{fetch(:db_pull_dir)}/#{fetch(:stage)}_schema.dump"
        end
    end

    task :load_local do
        run_locally do
            username, password, database, host, server_version = get_local_database_config()
            pwdcmd = password.nil? ? '' : "PGPASSWORD='#{password}' "

            execute(
                "docker",
                "run",
                "-e PGPASSWORD='#{password}'",
                "--net dev_#{host}",
                "--rm",
                "postgres:#{server_version}",
                "dropdb",
                "-U '#{username}'",
                "-h #{host}",
                "'#{database}'",
                raise_on_non_zero_exit: false
            )

            execute(
                "docker",
                "run",
                "-e PGPASSWORD='#{password}'",
                "--net dev_#{host}",
                "--rm",
                "postgres:#{server_version}",
                "createdb",
                "-U '#{username}'",
                "-h #{host}",
                "'#{database}'"
            )

            execute(
                "docker",
                "run",
                "-e PGPASSWORD='#{password}'",
                "-v $(pwd)/#{fetch(:db_pull_dir)}/#{fetch(:stage)}_schema.dump:/schema.dump",
                "--net dev_#{host}",
                "--rm",
                "postgres:#{server_version}",
                "pg_restore",
                "-U '#{username}'",
                "-h #{host}",
                "-d '#{database}'",
                "-c -j 8 --if-exists --no-owner",
                "/schema.dump"
            )

            execute(
                "docker",
                "run",
                "-e PGPASSWORD='#{password}'",
                "-v $(pwd)/#{fetch(:db_pull_dir)}/#{fetch(:stage)}_data.dump:/data.dump",
                "--net dev_#{host}",
                "--rm",
                "postgres:#{server_version}",
                "pg_restore",
                "-U '#{username}'",
                "-h #{host}",
                "-d '#{database}'",
                "-c",
                "/data.dump"
            )

        end
    end
end
