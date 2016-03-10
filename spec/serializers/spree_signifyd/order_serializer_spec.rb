require 'spec_helper'

module SpreeSignifyd
  describe OrderSerializer do
    let(:order) { create(:shipped_order, line_items_count: 1) }
    let(:line_item) { order.line_items.first }
    let(:serialized_order) { JSON.parse(OrderSerializer.new(order).to_json) }

    describe "node values" do
      context "purchase" do

        let(:purchase) { serialized_order['purchase'] }

        it { expect(purchase['browserIpAddress']).to eq order.last_ip_address }
        it { expect(purchase['orderId']).to eq order.number }
        it { expect(purchase['createdAt']).to eq order.completed_at.utc.iso8601 }
        it { expect(purchase['currency']).to eq order.currency }
        it { expect(purchase['totalPrice']).to eq order.total.to_s }

        context "with a payment" do
          it { expect(purchase['avsResponseCode']).to eq order.payments.last.avs_response }
          it { expect(purchase['cvvResponseCode']).to eq order.payments.last.cvv_response_code }

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

          it { expect(purchase['avsResponseCode']).to be nil }
          it { expect(purchase['cvvResponseCode']).to be nil }
        end

        it "contains a products node" do
          expect(purchase['products']).to eq [ JSON.parse(SpreeSignifyd::LineItemSerializer.new(line_item).to_json) ]
        end
      end

      context "userAccount" do
        it { expect(serialized_order).to include 'userAccount' }
      end

      context "recipient" do
        it { expect(serialized_order).to include 'recipient' }
        it { expect(serialized_order["recipient"]["confirmationEmail"]).to eq order.email }
      end

      context "card" do
        it { expect(serialized_order).to include 'card' }

        context "credit card payment" do
          let!(:payment) { create(:payment, order: order) }

          it { expect(serialized_order["card"]).to include 'billingAddress'}
        end

        context "no payment source" do
          let(:order) { create(:completed_order_with_totals) }

          it "contains no data" do
            expect(serialized_order["card"]).to eq({})
          end
        end

        context "non credit card payment" do
          it "contains no data" do
            allow_any_instance_of(Spree::CreditCard).to receive(:instance_of?).and_return(false)
            expect(serialized_order["card"]).to eq({})
          end
        end
      end
    end
  end
end
