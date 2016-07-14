module SpreeSignifyd::OrderConcerns
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, unless: :approved? do |order, transition|
      if order.send_to_signifyd?
        SpreeSignifyd.create_case(order_number: order.number)
      else
        SpreeSignifyd.approve(order: order)
      end
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

    def send_to_signifyd?
      !approved? &&
      !(SpreeSignifyd::Config[:exclude_store_credit_orders] && paid_completely_with_store_credit?)
    end

    private

    def paid_completely_with_store_credit?
      payments.all? do |payment|
        payment.payment_method.is_a?(Spree::PaymentMethod::StoreCredit)
      end
    end
  end
end
