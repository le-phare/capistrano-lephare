namespace :npm do

	desc 'Install node_modules'
	task install: :'nvm:binaries' do
		on roles(:app) do
			within release_path do
				execute :npm, 'install'
			end
		end
	end

	desc 'Run "build" script'
	task build: :'nvm:binaries' do
		on roles(:app) do
			within release_path do
				execute :npm, 'run', 'build'
			end
		end
	end

end
