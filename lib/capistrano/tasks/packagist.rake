namespace :packagist do
  desc "Authenticate in packagist.com"
  task :auth do
    invoke "composer:run", :config, "--global --auth http-basic.repo.packagist.com #{fetch(:packagist_username)} #{fetch(:packagist_token)}"
    Rake::Task["composer:run"].reenable
  end
end
