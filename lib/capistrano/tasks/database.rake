namespace :db do
    task :backup do
        invoke "#{fetch(:dbms)}:backup"
    end

    task :download do
        invoke "#{fetch(:dbms)}:load_local"
    end

    task :load_local do
        invoke "#{fetch(:dbms)}:load_local"
    end

    task :pull do
        invoke "db:backup"
        invoke "db:download"
        invoke "db:load_local"
    end
end

def get_remote_database_config()
    remote_config = capture("cat #{shared_path}/app/config/parameters.yml")
    config = YAML::load(remote_config)
    return config['parameters']['database_user'],
        config['parameters']['database_password'],
        config['parameters']['database_name'],
        config['parameters']['database_host'],
        config['parameters']['database_server_version']
end

def get_local_database_config()
    run_locally do
        config = capture("cat app/config/parameters.yml")
        config = YAML::load(config)
        return config['parameters']['database_user'],
            config['parameters']['database_password'],
            config['parameters']['database_name'],
            config['parameters']['database_host'],
            config['parameters']['database_server_version']
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
