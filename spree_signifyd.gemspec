# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_signifyd'
  s.version     = '2.2.2'
  s.summary     = 'Spree extension for communicating with Signifyd to check orders for fraud.'
  s.description = 'Spree extension for communicating with Signifyd to check orders for fraud.'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Bonobos'
  s.email     = 'engineering@bonobos.com'
  s.homepage  = 'http://www.bonobos.com'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'active_model_serializers', '0.9.0.alpha1'
  s.add_dependency 'resque', '~> 1.25.1'
  s.add_dependency 'signifyd'
  s.add_dependency 'spree_core', '2.2.2'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
