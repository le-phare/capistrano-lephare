namespace :crontab do
  desc <<-DESC
    Update the crontab
  DESC
  task :update do
    on roles(:web) do
      if test("[ -f #{fetch(:crontab_file)} ]")
        info "Update crontab with #{fetch(:crontab_file)}"
        execute "crontab #{fetch(:crontab_file)}"
      else
        info "No crontab found at #{fetch(:crontab_file)}"
      end
    end
  end
end
