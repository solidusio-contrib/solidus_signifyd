# frozen_string_literal: true

require 'spree/core'

module SolidusSignifyd
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions::Decorators

    isolate_namespace ::Spree

    engine_name 'solidus_signifyd'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.signifyd.environment", before: :load_config_initializers do |app|
      SolidusSignifyd::Config = Spree::SignifydConfiguration.new
      SolidusSignifyd::Config.use_static_preferences!
    end
  end
end
