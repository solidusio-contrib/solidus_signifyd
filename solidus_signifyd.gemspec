# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_signifyd'
  s.version     = '1.2.0'
  s.summary     = 'Solidus extension for communicating with Signifyd to check orders for fraud.'
  s.description = s.summary

  s.author    = 'Bonobos'
  s.email     = 'engineering@bonobos.com'
  s.homepage  = 'http://www.bonobos.com'

  s.required_ruby_version = '>= 2.1'
  s.license     = %q{BSD-3}

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  solidus_version = ['>= 1.0', '< 3']
  s.add_dependency 'active_model_serializers', '~> 0.10.7'
  s.add_dependency 'devise'
  s.add_dependency 'signifyd', '~> 0.1.5'
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_support'

  s.add_development_dependency 'json-schema'
  s.add_development_dependency 'solidus_extension_dev_tools'
end
