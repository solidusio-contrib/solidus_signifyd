require 'spec_helper'

module SpreeSignifyd
  describe LineItemSerializer do
    let(:line_item) { create(:line_item) }
    let(:serialized_line_item) { JSON.parse(LineItemSerializer.new(line_item).to_json) }

    context "node values" do
      it "itemId" do
        expect(serialized_line_item['itemId']).to eq line_item.variant_id
      end

      it "itemName" do
        expect(serialized_line_item['itemName']).to eq line_item.name
      end

      it "itemQuantity" do
        expect(serialized_line_item['itemQuantity']).to eq line_item.quantity
      end

      it "itemPrice" do
        expect(serialized_line_item['itemPrice']).to eq line_item.price.to_s
      end
    end
  end
end
