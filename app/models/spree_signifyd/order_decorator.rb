module SpreeSignifyd::OrderDecorator
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, unless: :approved? do |order, transition|
      SpreeSignifyd.create_case(order_id: order.id)
    end

    has_one :signifyd_order_score, class_name: "SpreeSignifyd::OrderScore"

    prepend(InstanceMethods)
  end

  module InstanceMethods
    def is_risky?
      if signifyd_order_score
        signifyd_order_score.score <= SpreeSignifyd::Config[:signifyd_score_threshold]
      else
        true
      end
    end
  end
end

Spree::Order.include SpreeSignifyd::OrderDecorator
