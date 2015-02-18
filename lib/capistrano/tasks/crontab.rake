namespace :crontab do

  desc "Lists tasks in user crontab"
  task :list do
    on roles(:app) do
      info "Lists tasks in '#{fetch(:stage)}' stage"
      capture(:crontab, "-l", "2>&1", "||", "true").each_line do |line|
        puts line
      end
    end
  end

  desc "Update user crontab"
  task :update do
    on roles(:app) do

      crontab_file = fetch(:crontab_file)

      if test("[ -f #{release_path}/#{crontab_file}.#{fetch(:stage)} ]")
        crontab_file = "#{crontab_file}.#{fetch(:stage)}"
      end

      if test("[ -f #{release_path}/#{crontab_file} ]")
        info "Update crontab with #{crontab_file}"
        execute :crontab, "#{release_path}/#{crontab_file}"
      else
        info "No crontab found at #{crontab_file}"
      end
    end
  end

  desc "Delete user crontab"
  task :delete do
    on roles(:app) do
      info "Delete tasks in '#{fetch(:stage)}' stage"
      capture(:crontab, "-r", "2>&1", "||", "true").each_line do |line|
        puts line
      end
    end
  end

end
