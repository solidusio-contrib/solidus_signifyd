require 'spec_helper'

module Spree::Api::SpreeSignifyd

  describe OrdersController do
    describe 'POST #update' do

      let(:order_number) { "19418" }
      let!(:order) { create(:completed_order_with_totals, number: order_number) }
      let!(:user) { create(:user) }
      let(:signifyd_sha) { 'sdGXFLSPZi5hTt8ZCVR9FeNMrsfmOblEIkpV2cCVLxM=' }

      let(:body) {
        {
          "analysisUrl" => "https://signifyd.com/v2/cases/1/analysis",
          "entriesUrl" => "https://signifyd.com/v2/cases/1/entries",
          "notesUrl" => "https://signifyd.com/v2/cases/1/notes",
          "orderUrl" => "https://signifyd.com/v2/cases/1/order",
          "status" => "DISMISSED",
          "uuid" => "709b9107-eda0-4cdd-bdac-a82f51a8a3f3",
          "headline" => "John Smith",
          "reviewDisposition" => nil,
          "associatedTeam" => {
            "teamName" => "anyTeam",
            "teamId" => 26,
            "getAutoDismiss" => true,
            "getTeamDismissalDays" => 2
            },
            "orderId" => order_number,
            "orderDate" => "2013-06-17T06:20:47-0700",
            "orderAmount" => 365.99,
            "createdAt" => "2013-11-05T14:23:26-0800",
            "updatedAt" => "2013-11-05T14:23:26-0800",
            "adjustedScore" => 262.6666666666667,
            "investigationId" => 1,
            "score" => 262.6666666666667,
            "caseId" => 1
          }
      }

      before { request.headers['HTTP_HTTP_X_SIGNIFYD_HMAC_SHA256'] = signifyd_sha }

      before(:all) do
        @api_key = SpreeSignifyd::Config[:api_key]
        @default_approver_email = SpreeSignifyd::Config[:default_approver_email]

        SpreeSignifyd::Config[:api_key] = 'ABCDE'
        SpreeSignifyd::Config[:default_approver_email] = user.email
      end

      after(:all) do
        SpreeSignifyd::Config[:api_key] = @api_key
        SpreeSignifyd::Config[:default_approver_email] = @default_approver_email
      end

      subject { post :update, body.to_json, { use_route: :spree } }

      context "invalid sha" do
        let(:signifyd_sha) { "INVALID" }

        it "does not set signifyd_score" do
          subject
          order.reload
          expect(order.signifyd_score).to eq nil
        end

        it "responds with 401" do
          subject
          expect(response.code.to_i).to eq 401
        end
      end

      context "valid sha" do
        context "invalid order number" do
          before(:each) { order.destroy! }

          it "responds with a 404" do
            subject
            expect(response.code.to_i).to eq 404
          end
        end

        context "the order has been shipped" do

          it "raises an error" do
            Spree::Order.any_instance.stub(:shipped?).and_return(true)
            expect{ subject }.to raise_error("Attempting to approve/deny order ##{order.number} via Signifyd, but it has already been shipped")
          end
        end

        context "the order has been canceled" do
          before(:each) { order.cancel! }

          it "raises an error" do
            expect{ subject }.to raise_error("Attempting to approve/deny order ##{order.number} via Signifyd, but it has already been canceled")
          end
        end

        context "valid order number" do
          it "sets the order's signifyd_score" do
            subject
            order.reload
            expect(order.signifyd_score).to eq 262
          end

          it "responds with 200" do
            subject
            expect(response.code.to_i).to eq 200
          end

          context "reviewDisposition is FRAUDULENT" do
            let(:signifyd_sha) { "ulHF48lbFO3M6UBMSi1tAroJWADeSggrr6V7ND8hBx0=" }

            before(:each) do
              @original_review_disposition = body['reviewDiposition']
              body['reviewDisposition'] = 'FRAUDULENT'
            end

            after(:each) { body['reviewDiposition'] = @original_review_disposition }

            it 'cancels the order' do
              Spree::Order.any_instance.should_receive(:cancel!)
              subject
            end
          end

          context "reviewDisposition is not FRAUDULENT" do
            context "the order has already been approved" do

              before(:each) { order.update_attribute(:approved_at, Time.now) }

              it "does not call signifyd_approve" do
                Spree::Order.any_instance.should_not_receive(:signifyd_approve)
                subject
              end
            end

            context "the order has not yet been approved" do
              context "the reviewDisposition is GOOD" do
                let(:signifyd_sha) { "wZIjgRQoDMWe0W4VoE5TJEoHf8ZcY9UeXY1lnGP+pfg=" }

                before(:each) do
                  Spree::Order.stub(:find_by).and_return(order) # Stub so rspec recognizes signifyd_approve
                  @original_review_disposition = body['reviewDisposition']
                  body['reviewDisposition'] = 'GOOD'
                end

                after(:each) { body['reviewDisposition'] = @original_review_disposition }

                it "calls signifyd_approve" do
                  order.should_receive(:signifyd_approve)
                  subject
                end
              end

              context "the reviewDisposition is not GOOD" do
                before(:each) { Spree::Order.stub(:find_by).and_return(order) }

                it "does not call signifyd_approve" do
                  order.should_not_receive(:signifyd_approve)
                  subject
                end
              end

              context "the order is not risky" do
                let(:signifyd_sha) { "ZI7bSCavfy6pWogJZ7nq2LbLLojcfcy9kjF02WHO4nM=" }

                before(:each) do
                  @original_score = body['adjustedScore']
                  body['adjustedScore'] = SpreeSignifyd::Config[:signifyd_score_threshold] + 1
                  Spree::Order.stub(:find_by).and_return(order)
                end

                after(:each) { body['adjustedScore'] = @original_score }

                it "approves the order" do
                  order.should_receive(:signifyd_approve)
                  subject
                end
              end

              context "the order is risky" do

                let(:signifyd_sha) { "YcEDVtPBAXcgQ9fJgBMSoBWy9CVpc6pnN6YzCbtD85E=" }

                before(:each) do
                  @original_score = body['adjustedScore']
                  body['adjustedScore'] = SpreeSignifyd::Config[:signifyd_score_threshold] - 1
                  Spree::Order.stub(:find_by).and_return(order)
                end

                after(:each) { body['adjustedScore'] = @original_score }

                it "does not approve the order" do
                  order.should_not_receive(:signifyd_approve)
                  subject
                end
              end
            end
          end
        end
      end
    end
  end
end
