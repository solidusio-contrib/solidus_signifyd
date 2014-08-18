require 'spec_helper'

module SpreeSignifyd
  describe OrderSerializer do
    let(:order) { create(:shipped_order) }
    let(:serialized_order) { JSON.parse(OrderSerializer.new(order).to_json) }

    describe "node values" do
      context "purchase" do

        let(:purchase) { serialized_order['purchase'] }

        it "browserIpAddress" do
          purchase['browserIpAddress'].should eq order.last_ip_address
        end

        it "orderId" do
          purchase['orderId'].should eq order.number
        end

        it "createdAt" do
          purchase['createdAt'].should eq order.completed_at.utc.iso8601
        end

        it "currency" do
          purchase['currency'].should eq order.currency
        end

        it "totalPrice" do
          purchase['totalPrice'].should eq order.total.to_s
        end
      end

      context "userAccount" do
        it { serialized_order.should include 'userAccount' }
      end

      context "recipient" do
        it { serialized_order.should include 'recipient' }

        it "includes the confirmationEmail" do
          serialized_order["recipient"]["confirmationEmail"].should eq order.email
        end
      end
    end
  end
end
