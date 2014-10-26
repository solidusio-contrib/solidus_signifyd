require 'spec_helper'

module SpreeSignifyd
  describe AddressSerializer do
    let(:ship_address) { create(:address) }
    let(:serialized_address) { JSON.parse(AddressSerializer.new(ship_address).to_json) }

    context "node values" do
      let(:address) { serialized_address['address'] }

      it "streetAddress" do
        expect(address['streetAddress']).to eq ship_address.address1
      end

      it "unit" do
        expect(address['unit']).to eq ship_address.address2
      end

      it "city" do
        expect(address['city']).to eq ship_address.city
      end

      describe "provinceCode" do
        it "with a state entity associated" do
          expect(address['provinceCode']).to eq ship_address.state.abbr
        end
        it "with a state_name and no state entity" do
          ship_address.update_attributes!(state_name: ship_address.state.name, state_id: nil)
          expect(address['provinceCode']).to eq ship_address.state_name
        end
      end

      it "postalCode" do
        expect(address['postalCode']).to eq ship_address.zipcode
      end

      it "countryCode" do
        expect(address['countryCode']).to eq ship_address.country.iso
      end
    end
  end
end
