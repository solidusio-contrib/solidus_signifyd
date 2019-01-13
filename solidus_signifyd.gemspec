# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "solidus_signifyd"
  s.version     = "1.2.0"
  s.summary     = "Solidus extension for communicating with Signifyd to check orders for fraud."
  s.description = s.summary

  s.author    = "Bonobos"
  s.email     = "engineering@bonobos.com"
  s.homepage  = "http://www.bonobos.com"

  s.required_ruby_version = ">= 2.1"
  s.license     = %q{BSD-3}

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = "lib"
  s.requirements << "none"

  s.add_dependency "active_model_serializers", "~> 0.10.7"
  s.add_dependency "signifyd", "~> 0.1.5"
  s.add_dependency "solidus_core", [">= 1.0", "< 3"]
  s.add_dependency "solidus_api", [">= 1.0", "< 3"]
  s.add_dependency "solidus_backend", [">= 1.0", "< 3"]
  s.add_dependency "solidus_support"
  s.add_dependency "devise"

  s.add_development_dependency "rspec-rails",  "~> 3.4"
  s.add_development_dependency "capybara-screenshot"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "json-schema"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "ffaker"
end
