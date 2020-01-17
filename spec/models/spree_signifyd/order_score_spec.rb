require 'spec_helper'

describe SolidusSignifyd::OrderScore, type: :model do
  let!(:order) { create(:order_ready_to_ship, line_items_count: 1) }
  let!(:order_score) { described_class.create!(order: order, score: 100, case_id: 1) }

  describe '#build_case_url' do
    subject { order_score.build_case_url }

    context 'no case_id' do
      let!(:order_score) { described_class.create!(order: order, score: 100, case_id: nil) }

      it 'will raise a MissingCaseId error' do
        expect{ subject }.to raise_error(SolidusSignifyd::OrderScore::MissingCaseId)
      end
    end

    context 'case_id and signifyd_dashboard_case_url' do
      it 'uses the url from the config to determine url' do
        expect(subject).to match('https://app.signifyd.com/cases/1')
      end
    end
  end
end
