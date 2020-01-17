require 'spec_helper'

module SolidusSignifyd
  describe AddressSerializer do
    let(:serialized_address) { JSON.parse(AddressSerializer.new(ship_address).to_json) }

    def ship_address(options = {})
      @ship_address ||= create(:address, options)
    end

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
          ship_address(state_name: 'AL', state_id: nil)
          expect(address['provinceCode']).to eq 'AL'
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
