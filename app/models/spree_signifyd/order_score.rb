module SpreeSignifyd
  class OrderScore < ActiveRecord::Base
    class MissingCaseId < StandardError; end
    self.table_name = :spree_signifyd_order_scores

    belongs_to :order, class_name: "Spree::Order"
    validates :score, numericality: true
    validates :order, presence: true

    def build_case_url
      signifyd_url = SpreeSignifyd::Config[:signifyd_dashboard_case_url]

      raise MissingCaseId if case_id.blank?

      signifyd_url.gsub(/:case_id/, ERB::Util.url_encode(case_id))
    end
  end
end
