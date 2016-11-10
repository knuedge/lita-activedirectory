Gem::Specification.new do |spec|
  spec.name          = 'lita-activedirectory'
  spec.version       = '0.0.8'
  spec.authors       = ['Daniel Schaaff']
  spec.email         = ['dschaaff@knuedge.com']
  spec.description   = 'ldap/active directory instructions for Lita'
  spec.summary       = 'Allow Lita to interact with Active Directory'
  spec.homepage      = 'https://github.com/knuedge/lita-activedirectory'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.2'

  spec.add_runtime_dependency 'lita', '>= 4.7'
  spec.add_runtime_dependency 'cratus'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'travis', '~> 1.8'
end
