namespace :librato do
  desc "Annotate the deployment in librato."
  task :annotate do
    on roles(:web) do
      if fetch(:librato_username)
        execute "curl -s -u #{fetch(:librato_username)}:#{fetch(:librato_token)} \
          -d 'title=#{fetch(:release_path)}&description=#{fetch(:current_revision)}&source=#{fetch(:domain)}' \
          -X POST https://metrics-api.librato.com/v1/annotations/deploy"
      end
    end
  end
end
