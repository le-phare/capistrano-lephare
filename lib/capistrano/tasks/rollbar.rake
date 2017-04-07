namespace :rollbar do
  task :notify do
    on roles(:app) do |h|
      $stderr.puts(<<-MESSAGE)
[Deprecation Notice] Use officialy supported rollbar plugin for capistrano

See https://rollbar.com/docs/deploys/capistrano/

Add to your Gemfile:

    gem 'rollbar', '~>1.2.7'

Add to your Capfile:

    require 'rollbar/capistrano3'

Add to your deploy.rb:

    set :rollbar_token, 'POST_SERVER_ITEM_ACCESS_TOKEN'
    set :rollbar_env, Proc.new { fetch :stage }
    set :rollbar_role, Proc.new { :app }

Then remove from deploy.rb

    after :finishing, "rollbar:notify"

MESSAGE

      if fetch(:rollbar_token)
        revision = `git log -n 1 --pretty=format:"%H"`
        local_user = `whoami`.strip!
        execute "curl -s -F access_token=#{fetch(:rollbar_token)} -F environment=#{fetch(:stage)} -F revision=#{revision} -F local_username=#{local_user} https://api.rollbar.com/api/1/deploy/", :once => true
      end
    end
  end
end
