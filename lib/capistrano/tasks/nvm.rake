namespace :nvm do

	desc 'Clone nvm repository'
	task :install do
		on release_roles(fetch(:nvm_roles)) do
				execute :git , 'clone', 'https://github.com/creationix/nvm.git', fetch(:nvm_path)
		end
	end

	desc 'Validate nvm install'
	task :validate do
		on release_roles(fetch(:nvm_roles)) do
			if not test("[ -d .nvm ]")
				Rake::Task["nvm:install"].invoke
			end
		end
	end

	desc 'Wrap binaries for SSHKit'
	task binaries: :'nvm:wrapper' do
		SSHKit.config.default_env.merge!({
			node_version: "#{fetch(:nvm_node, 'stable')}",
		})
		nvm_prefix = fetch(:nvm_prefix, -> { "#{fetch(:tmp_dir)}/#{fetch(:application)}/nvm-exec.sh" } )
		fetch(:nvm_map).each do |command|
			SSHKit.config.command_map.prefix[command.to_sym].unshift(nvm_prefix)
		end
	end

	desc 'Setup node and npm wrappers'
	task wrapper: :'nvm:validate' do
		on release_roles(fetch(:nvm_roles)) do

			execute :mkdir, "-p", "#{fetch(:tmp_dir)}/#{fetch(:application)}/"

			upload! StringIO.new(<<-EOS), "#{fetch(:tmp_dir)}/#{fetch(:application)}/nvm-exec.sh"
			#!/bin/bash -e
			source #{fetch(:nvm_path)}/nvm.sh

			nvm install $NODE_VERSION 2> /dev/null
			nvm use --delete-prefix $NODE_VERSION

			exec "$@"
			EOS

			execute :chmod, "+x", "#{fetch(:tmp_dir)}/#{fetch(:application)}/nvm-exec.sh"
		end
	end
end

namespace :load do
	task :defaults do

		set :nvm_path, -> {
			nvm_path = fetch(:nvm_custom_path)
			nvm_path ||= if fetch(:nvm_type, :user) == :system
				"/usr/local/nvm"
			else
				"$HOME/.nvm"
			end
		}

		set :nvm_roles, fetch(:nvm_roles, :all)
		set :nvm_map, %w{node npm}
	end
end
