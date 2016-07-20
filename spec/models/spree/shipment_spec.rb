require 'spec_helper'

describe Spree::Shipment, :type => :model do

  let(:shipment) { create(:shipment) }
  subject { shipment.determine_state(shipment.order) }

  describe "#determine_state" do
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

      describe "regular Solidus behaviour" do
        context "order cannot ship" do
          before { allow(shipment.order).to receive_messages can_ship?: false }

          it 'returns pending' do
            expect(subject).to eq 'pending'
          end
        end

        context "order can ship" do
          before { allow(shipment.order).to receive_messages can_ship?: true }

          it 'returns shipped when already shipped' do
            allow(shipment).to receive_messages state: 'shipped'
            expect(subject).to eq 'shipped'
          end

          it 'returns pending when unpaid' do
            allow(shipment.order).to receive_messages paid?: false
            expect(subject).to eq 'pending'
          end

          it 'returns ready when paid' do
            allow(shipment.order).to receive_messages paid?: true
            expect(subject).to eq 'ready'
          end
        end
      end
    end
  end
end
