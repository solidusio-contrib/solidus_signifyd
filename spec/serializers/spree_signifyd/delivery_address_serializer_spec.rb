require 'spec_helper'

module SpreeSignifyd
  describe DeliveryAddressSerializer do
    let(:delivery_address) { create(:address) }
    let(:serialized_address) { JSON.parse(DeliveryAddressSerializer.new(delivery_address).to_json) }

    context "node values" do
      it { serialized_address.should include 'deliveryAddress' }
      it { serialized_address['fullName'].should eq delivery_address.full_name }
    end
  end
end
