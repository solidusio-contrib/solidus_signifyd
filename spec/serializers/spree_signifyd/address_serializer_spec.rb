require 'spec_helper'

module SpreeSignifyd
  describe AddressSerializer do
    let(:ship_address) { create(:address) }
    let(:serialized_address) { JSON.parse(AddressSerializer.new(ship_address).to_json) }

    context "node values" do
      it "fullName" do
        expect(serialized_address['fullName']).to eq ship_address.full_name
      end

      context "deliveryAddress node values" do
        let(:delivery_address) { serialized_address['deliveryAddress'] }

        it "streetAddress" do
          expect(delivery_address['streetAddress']).to eq ship_address.address1
        end

        it "unit" do
          expect(delivery_address['unit']).to eq ship_address.address2
        end

        it "city" do
          expect(delivery_address['city']).to eq ship_address.city
        end

        it "provinceCode" do
          expect(delivery_address['provinceCode']).to eq ship_address.state.abbr
        end

        it "postalCode" do
          expect(delivery_address['postalCode']).to eq ship_address.zipcode
        end

        it "countryCode" do
          expect(delivery_address['countryCode']).to eq ship_address.country.iso
        end
      end
    end
  end
end
