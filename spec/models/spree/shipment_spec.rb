require 'spec_helper'

describe Spree::Shipment, :type => :model do

  let(:shipment) { create(:shipment) }
  subject { shipment.determine_state(shipment.order) }

  describe "#determine_state_with_signifyd" do

    context "with a risky order" do
      before { shipment.order.stub(:is_risky?).and_return(true) }

      context "the order is not approved" do
        it "returns pending" do
          shipment.order.stub(:approved?).and_return(false)
          subject.should eq "pending"
        end
      end

      context "the order is approved" do
        it "defaults to existing behavior" do
          shipment.order.stub(:approved?).and_return(true)
          shipment.should_receive(:determine_state).with(shipment.order)
          subject
        end
      end
    end

    context "without a risky order" do
      before { shipment.order.stub(:is_risky?).and_return(false) }

      it "defaults to existing behavior" do
        shipment.should_receive(:determine_state).with(shipment.order)
        subject
      end
    end
  end
end
