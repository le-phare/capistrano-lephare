# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-lephare'
  spec.version       = '0.0.1'
  spec.authors       = ['Erwan Richard']
  spec.email         = ['erwan@lephare.com']
  spec.description   = %q{Le Phare tasks for Capistrano 3.x}
  spec.summary       = %q{Le Phare tasks for Capistrano 3.x}
  spec.homepage      = 'https://github.com/le-phare/capistrano-lephare'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.0.0.pre'
  spec.add_dependency 'sshkit', '1.7.1'
  spec.add_dependency 'capistrano-simple-formatter', '>= 0.2'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1'
end
