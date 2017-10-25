require 'spec_helper'

module SpreeSignifyd
  describe SpreeSignifyd do

    describe ".set_score" do

      let(:order) { FactoryBot.create(:order) }

      def set_score(score)
        SpreeSignifyd.set_score(order: order, score: score)
      end

      it 'creates or updates the score' do
        expect {
          set_score(100)
        }.to change { SpreeSignifyd::OrderScore.count }.by(1)

        expect(order.signifyd_order_score.score).to eq 100

        expect {
          set_score(200)
        }.not_to change { SpreeSignifyd::OrderScore.count }

        expect(order.signifyd_order_score.score).to eq 200
      end

    end

    describe ".set_case_id" do

      let(:order) { FactoryBot.create(:order) }
      let(:case_id) { 1}

      subject { SpreeSignifyd.set_case_id(order: order, case_id: case_id) }

      context 'when there is an existing SpreeSignifyd::OrderScore' do
        before do
          order.create_signifyd_order_score!(score: 100)
        end

        it 'updates the case_id' do
          expect {
            subject
          }.to change { order.signifyd_order_score.case_id }.from(nil).to(1)
        end
      end

      context 'when there is no existing SpreeSignifyd::OrderScore' do
        it 'does not update the case_id' do
          expect(order.signifyd_order_score).to eq nil
          expect{ subject }.not_to raise_error
        end
      end
    end

    describe ".approve" do

      let(:order) { FactoryBot.create(:order_ready_to_ship, line_items_count: 1) }

      before do
        order.shipments.each { |shipment| shipment.update_attributes!(state: 'pending') }
        order.updater.update_shipment_state
      end

      def approve
        SpreeSignifyd.approve(order: order)
      end

      context "updates the order" do
        it { expect { approve }.to change { order.approver_name }.to "SpreeSignifyd" }
        it { expect { approve }.to change { order.shipment_state }.to 'ready' }
        it do
          expect(order.approved_at).to eq nil
          expect { approve }.to change { order.approved_at }
        end
      end

      it 'readies all of the shipments' do
        order.shipments.each { |shipment| expect(shipment).to receive(:ready!) }
        approve
      end

      describe "when order has shipments that are not pending" do
        it "progresses the pending one(s) and ignores the rest" do
          shipped_shipment = order.shipments.create(state: :shipped)
          expect(shipped_shipment).to receive(:ready).never
          expect { approve }.to change { order.approved_at }
        end
      end

      context "with backordered stock" do
        before do
          order.inventory_units.first.update(state: 'backordered')
          order.reload
        end

        it "does not attempt invalid state changes" do
          approve
          expect(order.reload.shipments.first).to be_pending
        end
      end
    end

    describe ".create_case" do
      it 'enqueues in resque' do
        expect { SpreeSignifyd.create_case(order_number: 111) }.to have_enqueued_job(SpreeSignifyd::CreateSignifydCase)
      end
    end

  end
end
