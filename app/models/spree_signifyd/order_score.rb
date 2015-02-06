module SpreeSignifyd
  class OrderScore < ActiveRecord::Base
    self.table_name = :spree_signifyd_order_scores
    belongs_to :order, class_name: "Spree::Order"
    validates :score, numericality: true
    validates :order, presence: true
  end
end