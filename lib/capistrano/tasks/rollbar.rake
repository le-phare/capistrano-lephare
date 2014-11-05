namespace :rollbar do
  task :notify do
    on roles(:app) do |h|
      if fetch(:rollbar_token)
        revision = `git log -n 1 --pretty=format:"%H"`
        local_user = `whoami`
        execute "curl -s -F access_token=#{fetch(:rollbar_token)} -F environment=#{fetch(:stage)} -F revision=#{revision} -F local_username=#{local_user} https://api.rollbar.com/api/1/deploy/", :once => true
      end
    end
  end
end
