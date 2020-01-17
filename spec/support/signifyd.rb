RSpec.configure do |config|
  config.before :each do
    # allow us to test various preference settings without cross contamination
    SolidusSignifyd::Config.reset

    allow(Signifyd::Case)
      .to receive(:create)
        .and_return(code: 201, body: { investigationId: 123 })
  end
end
