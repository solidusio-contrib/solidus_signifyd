require 'spec_helper'

module SolidusSignifyd
  describe CreditCardSerializer do
    let(:credit_card) { create(:credit_card) }
    let(:serialized_credit_card) { JSON.parse(CreditCardSerializer.new(credit_card).to_json) }

    context "node values" do
      it "cardHolderName" do
        expect(serialized_credit_card['cardHolderName']).to eq SolidusSignifyd::Name.name_value(credit_card)
      end

      it "last4" do
        expect(serialized_credit_card['last4']).to eq credit_card.last_digits
      end

      it "expiryMonth" do
        expect(serialized_credit_card['expiryMonth']).to eq credit_card.month.to_i
      end

      it "expiryYear" do
        expect(serialized_credit_card['expiryYear']).to eq credit_card.year.to_i
      end
    end
  end
end
