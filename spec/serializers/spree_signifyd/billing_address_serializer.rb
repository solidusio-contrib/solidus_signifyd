require 'spec_helper'

module SpreeSignifyd
  describe BillingAddressSerializer do
    let(:bill_address) { create(:address) }
    let(:serialized_address) { JSON.parse(BillingAddressSerializer.new(bill_address).to_json) }

    context "node values" do
      it { expect(serialized_address).to include 'billingAddress' }
    end
  end
end
