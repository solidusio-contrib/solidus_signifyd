require 'spec_helper'

describe Spree::Order, :type => :model do

  let!(:order) { create(:order_ready_to_ship, line_items_count: 1) }

  describe "#complete_and_approved" do
    let!(:incomplete_order) { create(:order) }
    let!(:approved_order) { create(:order_ready_to_ship, line_items_count: 1, approved_at: Time.now) }

    it "only returns orders that are complete and approved" do
      expect(Spree::Order.complete_and_approved).to eq [approved_order]
    end
  end

  describe "#is_risky?" do
    subject { order.is_risky? }

    context "no signifyd_score" do
      it { should be true }
    end

    context "signifyd_score present" do
      let(:signifyd_score_threshold) { SpreeSignifyd::Config[:signifyd_score_threshold] }

      context "greater than threshold" do
        before { order.create_signifyd_order_score!(score: signifyd_score_threshold + 1) }
        it { should be_falsey }
      end

      context "less than threshold" do
        before { order.create_signifyd_order_score!(score: signifyd_score_threshold - 1) }
        it { should be_truthy }
      end
    end
  end

  describe "transition to complete" do
    let(:order) { create(:order_with_line_items, state: 'confirm') }
    let!(:payment) { create(:payment, amount: order.total, order: order ) }

    it "calls #create_signifyd_case" do
      expect(SpreeSignifyd).to receive(:create_case).with(order_id: order.id)
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
