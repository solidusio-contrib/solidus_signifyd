require 'spec_helper'

describe Spree::Order, :type => :model do

  let!(:order) { create(:order_ready_to_ship, line_items_count: 1) }

  describe "#is_risky?" do
    subject { order.is_risky? }

    context "no signifyd_score" do
      before { order.signifyd_score = nil }
      it { should be true }
    end

    context "signifyd_score present" do
      let(:signifyd_score_threshold) { SpreeSignifyd::Config[:signifyd_score_threshold] }

      context "greater than threshold" do
        before { order.signifyd_score = signifyd_score_threshold + 1 }
        it { should be false }
      end

      context "less than threshold" do
        before { order.signifyd_score = signifyd_score_threshold - 1 }
        it { should be true }
      end
    end
  end

  describe "#approved_by" do
    let(:user) { build(:user) }

    subject { order }

    context "updates the order" do

      before { subject.approved_by(user) }

      it 'sets approver_id' do
        expect(subject.approver_id).to eq user.id
      end

      it 'sets approved_at' do
        expect(subject.approved_at).to be_present
      end

      it 'is no longer risky' do
        expect(subject.considered_risky).to eq false
      end

      it 'updates the shipment state' do
        expect(subject.shipment_state).to eq 'ready'
      end
    end

    it 'updates all of the shipments' do
      subject.shipments.each { |shipment| shipment.should_receive(:update!) }
      subject.approved_by(user)
    end
  end
end
