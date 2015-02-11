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

      let(:order) { FactoryGirl.create(:order) }

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
