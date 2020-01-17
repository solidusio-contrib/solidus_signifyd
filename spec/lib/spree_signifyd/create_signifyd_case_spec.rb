require 'spec_helper'

module SolidusSignifyd
  describe CreateSignifydCase do
    describe "#perform" do
      let(:order) { create(:order_ready_to_ship) }
      let(:json) { JSON.parse(OrderSerializer.new(order).to_json) }

      it "calls Signifyd::Case#create with the correct params" do
        expect(Signifyd::Case).to receive(:create).with(json, SolidusSignifyd::Config[:api_key])
        CreateSignifydCase.perform_now(order.id)
      end

      it "calls Signifyd::Case#create with the correct params" do
        expect(Signifyd::Case).to receive(:create).with(json, SolidusSignifyd::Config[:api_key])
        CreateSignifydCase.perform_now(order.number)
      end
    end
  end
end
