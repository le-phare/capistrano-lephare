# capistrano-lephare

Capistrano tasks used to deploy Symfony based projects at Le Phare.

## Workflow

The default capistrano workflow is used with the addition of theses tasks.

    after 'deploy:starting', 'composer:install_executable'
    after 'deploy:publishing', 'symfony:assets:install'
    after 'deploy:finishing', 'deploy:migrate'
    after 'deploy:finished', 'deploy:cleanup'

## Tasks

### apc:cache:clear

Used to clear the APC cache at the end of the deployement. We recomend using it after after 'deploy:finishing'.

    after 'deploy:finishing', 'apc:cache:clear'

The task will put a `apc_clear_{revision}.php` file in the :webroot folder and call it via a local curl command.
The call is looped until it return the good revision.

### apc:monitor:enable

Enable the apc monitor.

### apc:monitor:disable

Disable the apc monitor.

### crontab:update

Update the crontab with `:crontab_file`. We recomend using it after after 'deploy:finishing'.

    after 'deploy:finishing', 'crontab:update'

### mysql:backup

Backup the remote database in `#{fetch(:deploy_to)}/backups`. We use mysqldump command with `:mysqldump_args`.
The command only keep  `:keep_db_backups` backups.

### mysql:pull

Backup the remote database, download the backup in `:db_pull_filename` and restore it locally.

### deploy:with_assets

Launch a deploy with assets uploading.

### deploy:publish_assets

Publish assets declared in `:assets_path` on remote server.

### deploy:migrate

Launch symfony `doctrine:migration:migrate` command.

### deploy:no_robots

Put a robots.txt that disallow robot indexing

### deploy:secure

Secure the application by putting a htpasswd authentification.
The credential are defined by `:htpasswd_user` and `:htpasswd_pwd` variables and you can whitelist IP with `:htpasswd_whitelist`.

### librato:annotate

Push a librato annotation with `:librato_username` and `:librato_token`.

## Options

Look at [defaults.rb](lib/capistrano/lephare/defaults.rb) to view defaults values.
