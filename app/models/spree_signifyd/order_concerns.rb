module SpreeSignifyd::OrderConcerns
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, unless: :approved? do |order, transition|
      SpreeSignifyd.create_case(order_number: order.number)
    end

    has_one :signifyd_order_score, class_name: "SpreeSignifyd::OrderScore"

    prepend(InstanceMethods)
  end

  module InstanceMethods
    def is_risky?
      !(awaiting_approval? || approved?)
    end

    def awaiting_approval?
      !signifyd_order_score
    end
  end
end
