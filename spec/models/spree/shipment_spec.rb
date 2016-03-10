require 'spec_helper'

describe Spree::Shipment, :type => :model do

  let(:shipment) { create(:shipment) }
  subject { shipment.determine_state(shipment.order) }

  describe "#determine_state_with_signifyd" do

    context "with a risky order" do
      before { allow(shipment.order).to receive(:is_risky?).and_return(true) }

      context "the order is not approved" do
        it "returns pending" do
          allow(shipment.order).to receive(:approved?).and_return(false)
          expect(subject).to eq "pending"
        end
      end

      context "the order is approved" do
        it "defaults to existing behavior" do
          allow(shipment.order).to receive(:approved?).and_return(true)
          expect(shipment).to receive(:determine_state).with(shipment.order)
          subject
        end
      end
    end

    context "without a risky order" do
      before { allow(shipment.order).to receive(:is_risky?).and_return(false) }

      it "defaults to existing behavior" do
        expect(shipment).to receive(:determine_state).with(shipment.order)
        subject
      end
    end

    context "shipment state" do
      [:shipped, :ready].each do |state|
        context "the shipment is #{state}" do
          before { shipment.update_columns(state: state) }
          it "defaults to existing behavior" do
            expect(shipment).to receive(:determine_state).with(shipment.order)
            subject
          end
        end
      end

      [:pending, :canceled].each do |state|
        context "the shipment is #{state}" do
          before { shipment.update_columns(state: state) }
          it "is pending" do
            expect(subject).to eq "pending"
          end
        end
      end
    end
  end
end
