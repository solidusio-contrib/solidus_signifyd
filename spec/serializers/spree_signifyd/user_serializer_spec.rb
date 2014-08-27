require 'spec_helper'

module SpreeSignifyd
  describe UserSerializer do
    let(:user) { create(:user) }
    let!(:incomplete_order) { create(:order, user: user) }
    let!(:old_complete_order) { create(:shipped_order, user: user, created_at: 30.days.ago) }
    let!(:new_complete_order) { create(:shipped_order, user: user) }

    let(:serialized_user) { JSON.parse(UserSerializer.new(user).to_json) }

    context "node values" do
      it "emailAddress" do
        expect(serialized_user['emailAddress']).to eq user.email
      end

      it "username" do
       expect(serialized_user['username']).to eq user.email
      end

      it "createdDate" do
       expect(serialized_user['createdDate']).to eq user.created_at.utc.iso8601
      end

      it "lastUpdateDate" do
       expect(serialized_user['lastUpdateDate']).to eq user.updated_at.utc.iso8601
      end

      context "with at least 2 orders" do
        it "lastOrderId" do
          expect(serialized_user['lastOrderId']).to eq old_complete_order.number
        end
      end

      context "without prior orders" do
        let(:user_without_orders) { create(:user) }
        let(:serialized_user) { JSON.parse(UserSerializer.new(user_without_orders).to_json) }

        it "lastOrderId" do
          expect(serialized_user['lastOrderId']).to eq nil
        end
      end

      it "aggregateOrderCount" do
        expect(serialized_user['aggregateOrderCount']).to eq 2
      end

      it "aggregateOrderDollars" do
        expect(serialized_user['aggregateOrderDollars']).to eq (old_complete_order.total + new_complete_order.total).to_s
      end
    end
  end
end
