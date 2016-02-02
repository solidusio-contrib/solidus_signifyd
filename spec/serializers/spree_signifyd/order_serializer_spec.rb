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
          it { purchase['avsResponseCode'].should eq order.payments.last.avs_response }
          it { purchase['cvvResponseCode'].should eq order.payments.last.cvv_response_code }

          context "when the payment is a paypal payment" do
            before do
              order.payments.first.source.update({
                cc_type: "paypal"
              })
            end

            it "includes a paymentGateway specification for signifyd" do
              expect(purchase['paymentGateway']).to eql("paypal_account")
            end
          end

          context "when the payment is not a paypal payment" do
            it "does not include a paymentGateway key" do
              expect(purchase['paymentGateway']).to eql(nil)
            end
          end
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
