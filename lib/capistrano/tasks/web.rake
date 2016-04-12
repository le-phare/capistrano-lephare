namespace :web do
  task :open do
    run_locally do
      domain = fetch(:domain)
      if not domain.match(/:\/\//)
        domain = "http://#{domain}"
      end

      execute "xdg-open #{domain}"
    end
  end
end
