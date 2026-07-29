# frozen_string_literal: true

require_relative 'lib/tau/version'

Gem::Specification.new do |spec|
  spec.name          = 'tau'
  spec.version       = Tau::VERSION
  spec.authors       = ['David Siaw']
  spec.email         = ['874280+davidsiaw@users.noreply.github.com']

  spec.summary       = 'A minimal Ruby agent framework'
  spec.description   = 'A simple agent implementation with step-based execution'
  spec.homepage      = 'https://github.com/davidsiaw/tau'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/davidsiaw/tau'
  spec.metadata['changelog_uri'] = 'https://github.com/davidsiaw/tau'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['{exe,data,lib}/**/*'] + %w[Gemfile tau.gemspec]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sqlite3', '~> 2.0'
  spec.add_dependency 'sqlite-vec', '~> 0.1'
end
