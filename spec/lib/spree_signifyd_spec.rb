require 'spec_helper'

module SpreeSignifyd
  describe SpreeSignifyd do

    describe ".set_score" do

      let(:order) { FactoryGirl.create(:order) }

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

    describe ".approve" do

      let(:order) { FactoryGirl.create(:order_ready_to_ship, line_items_count: 1) }

      def approve
        SpreeSignifyd.approve(order: order)
      end

      context "no default_approver" do
        it 'raises an error' do
          expect {
            approve
          }.to raise_error(SpreeSignifyd::DefaultApproverNotFound)
        end
      end

      context "default_approver exists" do
        let(:user) { create(:user) }

        around do |example|
          previous = SpreeSignifyd::Config[:default_approver_email]
          SpreeSignifyd::Config[:default_approver_email] = user.email

          example.run

          SpreeSignifyd::Config[:default_approver_email] = previous
        end

        it "calls approved_by with the default approver user" do
          expect(order).to receive(:approved_by).with(user)
          approve
        end

        context "updates the order" do
          it { expect { approve }.to change { order.approver_id }.to user.id }
          it { expect { approve }.to change { order.considered_risky }.to false }
          it { expect { approve }.to change { order.shipment_state }.to 'ready' }
          it do
            expect(order.approved_at).to eq nil
            expect { approve }.to change { order.approved_at }
          end
        end

        it 'updates all of the shipments' do
          order.shipments.each { |shipment| shipment.should_receive(:update!) }
          approve
        end
      end

    end

    describe ".create_case" do
      it 'enqueues in resque' do
        expect(Resque).to receive(:enqueue).with(SpreeSignifyd::CreateSignifydCase, 111)
        SpreeSignifyd.create_case(order_id: 111)
      end
    end

  end
end
