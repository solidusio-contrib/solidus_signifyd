# Run Coverage report
require "simplecov"
SimpleCov.start do
  add_filter "spec/dummy"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Models", "app/models"
  add_group "Views", "app/views"
  add_group "Libraries", "lib"
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("dummy/config/environment.rb", __dir__)

require "spree/testing_support/factories"
require "solidus_support/extension/feature_helper"

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.before :each do
    # allow us to test various preference settings without cross contamination
    SpreeSignifyd::Config.reset

    allow(Signifyd::Case)
      .to receive(:create)
      .and_return(code: 201, body: { investigationId: 123 })
  end
end
