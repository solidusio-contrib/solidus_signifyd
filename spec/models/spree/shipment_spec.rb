require 'spec_helper'

describe Spree::Shipment, :type => :model do

  let(:shipment) { create(:shipment) }
  subject { shipment.determine_state(shipment.order) }

  describe "#determine_state_with_signifyd" do
    context "with a canceled order" do
      before do
        shipment.order.update(state: 'canceled')
        shipment.update(state: 'canceled')
      end

      it "canceled shipments remain canceled" do
        expect(subject).to eq "canceled"
      end
    end

    context "with an approved order" do
      before { shipment.order.contents.approve(name: 'test approver') }

      it "pending shipments remain pending" do
        expect(subject).to eq "pending"
      end
    end

    [:shipped, :ready].each do |state|
      context "the shipment is #{state}" do
        before { shipment.update(state: state) }
        it "defaults to existing behavior" do
          expect(shipment).to receive(:determine_state).with(shipment.order)
          subject
        end
      end
    end
  end
end
