# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_signifyd/version'

Gem::Specification.new do |s|
  s.name = 'solidus_signifyd'
  s.version = SolidusSignifyd::VERSION
  s.summary = 'Solidus extension for communicating with Signifyd to check orders for fraud.'
  s.license = 'BSD-3-Clause'

  s.author = 'Bonobos'
  s.email = 'engineering@bonobos.com'
  s.homepage = 'http://www.bonobos.com'

  if s.respond_to?(:metadata)
    s.metadata["homepage_uri"] = s.homepage if s.homepage
    s.metadata["source_code_uri"] = 'https://github.com/solidusio-contrib/solidus_signifyd'
  end

  s.required_ruby_version = ['>= 2.4', '< 4.0']

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  solidus_version = ['>= 2.0', '< 4']
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_backend', solidus_version

  s.add_dependency 'active_model_serializers', '~> 0.10.7'
  s.add_dependency 'devise'
  s.add_dependency 'signifyd', '~> 0.1.5'
  s.add_dependency 'solidus_support', '~> 0.8'

  s.add_development_dependency 'json-schema'
  s.add_development_dependency 'solidus_dev_support'
end
