require 'spec_helper'

module SpreeSignifyd
  describe OrderSerializer do
    let(:order) { create(:shipped_order, line_items_count: 1) }
    let(:line_item) { order.line_items.first }
    let(:serialized_order) { JSON.parse(OrderSerializer.new(order).to_json) }

    describe "node values" do
      context "purchase" do

        let(:purchase) { serialized_order['purchase'] }

        it { purchase['browserIpAddress'].should eq order.last_ip_address }
        it { purchase['orderId'].should eq order.number }
        it { purchase['createdAt'].should eq order.completed_at.utc.iso8601 }
        it { purchase['currency'].should eq order.currency }
        it { purchase['totalPrice'].should eq order.total.to_s }

        context "with a payment" do
          it { purchase['avsResponseCode'].should eq order.latest_payment.avs_response }
          it { purchase['cvvResponseCode'].should eq order.latest_payment.cvv_response_code }
        end

        context "without a payment" do
          let(:order) { create(:completed_order_with_totals) }

          it { purchase['avsResponseCode'].should be nil }
          it { purchase['cvvResponseCode'].should be nil }
        end

        it "contains a products node" do
          purchase['products'].should eq [ JSON.parse(SpreeSignifyd::LineItemSerializer.new(line_item).to_json) ]
        end
      end

      context "userAccount" do
        it { serialized_order.should include 'userAccount' }
      end

      context "recipient" do
        it { serialized_order.should include 'recipient' }
        it { serialized_order["recipient"]["confirmationEmail"].should eq order.email }
      end

      context "card" do
        it { serialized_order.should include 'card' }

        context "credit card payment" do
          let!(:payment) { create(:payment, order: order) }

          it { serialized_order["card"].should include 'billingAddress'}
        end

        context "no payment source" do
          let(:order) { create(:completed_order_with_totals) }

          it "contains no data" do
            expect(serialized_order["card"]).to eq({})
          end
        end

        context "non credit card payment" do
          it "contains no data" do
            Spree::CreditCard.any_instance.stub(:instance_of?).and_return(false)
            expect(serialized_order["card"]).to eq({})
          end
        end
      end
    end
  end
end
