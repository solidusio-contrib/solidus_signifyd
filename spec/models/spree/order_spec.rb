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
      it { is_expected.to eq false }
    end

    context "signifyd_score present" do
      before { SpreeSignifyd.set_score(score: 500, order: order) }

      context "approved" do
        before { SpreeSignifyd.approve(order: order) }
        it { is_expected.to eq false }
      end

      context "not approved" do
        it { is_expected.to eq true }
      end
    end
  end

  describe "transition to complete" do
    let(:order) { create(:order_with_line_items, state: 'confirm') }

    shared_examples "an order we send to signifyd" do
      it "creates a new SIGNIFYD case" do
        expect(SpreeSignifyd).to receive(:create_case).with(order_number: order.number)
        order.complete!
      end
    end

    shared_examples "an order we DO NOT send to signifyd" do
      it "does not create a new SIGNIFYD case" do
        expect(SpreeSignifyd).not_to receive(:create_case)
        order.complete!
      end
    end

    context "paid with store credit only" do
      let!(:payment) { create(:store_credit_payment, amount: order.total, order: order ) }

      it_behaves_like "an order we send to signifyd"

      context "don't send store credit orders to SIGNIFYD" do
        before { SpreeSignifyd::Config[:exclude_store_credit_orders] = true }

        it_behaves_like "an order we DO NOT send to signifyd"

        it "is immediately approved" do
          expect{ order.complete! }.to change{ order.approved? }.from(false).to(true)
        end
      end
    end

    context "paid with cash" do
      let!(:payment) { create(:payment, amount: order.total, order: order ) }

      it_behaves_like "an order we send to signifyd"

      context "the order is already approved" do # e.g. unreturned exchanges are automatically approved
        before { order.contents.approve(user: Spree.user_class.first) }

        it_behaves_like "an order we DO NOT send to signifyd"
      end
    end
  end
end
