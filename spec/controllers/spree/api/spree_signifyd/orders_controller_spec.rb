require 'spec_helper'

module Spree::Api::SpreeSignifyd

  describe OrdersController do
    describe 'POST #update' do

      let(:order_number) { "19418" }
      let!(:order) { create(:order, number: order_number) }
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

      before do
        request.headers['HTTP_X_SIGNIFYD_HMAC_SHA256'] = signifyd_sha
        request.stub(:raw_post).and_return(body.to_json)
      end

      before(:all) do
        @api_key = SpreeSignifyd::Config[:api_key]
        SpreeSignifyd::Config[:api_key] = 'ABCDE'
      end

      after(:all) { SpreeSignifyd::Config[:api_key] = @api_key }

      subject { spree_post :update, body }

      context "invalid order number" do
        before { Spree::Order.stub(:find_by).and_return(nil) }

        it "responds with a 404" do
          subject
          expect(response.code.to_i).to eq 404
        end
      end

      context "valid order number" do
        context "valid sha" do
          it "sets the order's signifyd_score" do
            subject
            order.reload
            expect(order.signifyd_score).to eq 262
          end

          it "responds with 200" do
            subject
            expect(response.code.to_i).to eq 200
          end
        end

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
      end
    end
  end
end
