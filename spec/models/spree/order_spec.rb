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
        it { should be false }
      end

      context "less than threshold" do
        before { order.create_signifyd_order_score!(score: signifyd_score_threshold - 1) }
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

  describe "#signifyd_approve" do

    subject { order.signifyd_approve }

    context "no default_approver" do
      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end

    context "default_approver exists" do
      let(:user) { create(:user) }

      before(:each) do
        @default_approver_email = SpreeSignifyd::Config[:default_approver_email]
        SpreeSignifyd::Config[:default_approver_email] = user.email
      end

      after(:each) { @default_approver_email = SpreeSignifyd::Config[:default_approver_email] }

      it "calls approved_by with the default approver user" do
        order.should_receive(:approved_by).with(user)
        subject
      end
    end
  end

  describe "#lastest_payment" do
    let(:order) { create(:order) }
    let!(:old_payment) { create(:payment, order: order, created_at: 30.days.ago)}
    let!(:new_payment) { create(:payment, order: order) }

    it "finds the latest payment" do
      expect(order.latest_payment).to eq new_payment
    end
  end

  describe "transition to complete" do
    let(:order) { create(:order_with_line_items, state: 'confirm') }
    let!(:payment) { create(:payment, amount: order.total, order: order ) }

    it "calls #create_signifyd_case" do
      order.should_receive(:create_signifyd_case)
      order.complete!
    end
  end

  describe "#signifyd_score" do
    subject { order.signifyd_score }
    before { order.update_column(:signifyd_score, 500) }

    context "no signifyd_order_score" do
      it { should eq 500 }
    end

    context "signifyd_order_score is present" do
      before { order.create_signifyd_order_score!(score: 700) }
      it { should eq 700 }
    end
  end

  describe "#set_signifyd_score" do
    def set_score
      order.set_signifyd_score(500)
    end

    describe 'spree_orders.signifyd_score column' do
      subject { order.read_attribute(:signifyd_score) }
      before { set_score }
      it { should eq 500 }
    end

    describe 'order.signifyd_order_score' do
      subject { order.signifyd_order_score.score }

      context 'no score exists' do
        before { set_score }
        it { should eq 500 }
      end

      context 'a score already exists' do
        before do
          order.create_signifyd_order_score!(score: 100)
          set_score
        end
        it { should eq 500 }
      end
    end
  end
end
