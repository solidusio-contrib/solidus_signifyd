require 'spec_helper'

describe Spree::Order, :type => :model do

  let!(:order) { create(:order_ready_to_ship, line_items_count: 1) }

  before do
    order.shipments.each { |shipment| shipment.update_attributes!(state: 'pending') }
    order.updater.update_shipment_state
  end

  describe "#is_risky?" do
    subject { order.is_risky? }

    context "no signifyd_score" do
      it { should eq false }
    end

    context "signifyd_score present" do
      before { SpreeSignifyd.set_score(score: 500, order: order) }

      context "approved" do
        before { SpreeSignifyd.approve(order: order) }
        it { should eq false }
      end

      context "not approved" do
        it { should eq true }
      end
    end
  end

  describe "transition to complete" do
    let(:order) { create(:order_with_line_items, state: 'confirm') }
    let!(:payment) { create(:payment, amount: order.total, order: order ) }

    it "calls #create_signifyd_case" do
      expect(SpreeSignifyd).to receive(:create_case).with(order_number: order.number)
      order.complete!
    end

    context "the order is already approved" do # e.g. unreturned exchanges are automatically approved
      it "does not create a case" do
        order.contents.approve(user: Spree.user_class.first)
        expect(SpreeSignifyd).not_to receive(:create_case)
        order.complete!
      end
    end
  end

end
