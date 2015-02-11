module SpreeSignifyd::OrderDecorator
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, unless: :approved? do |order, transition|
      SpreeSignifyd.create_case(order_id: order.id)
    end

    has_one :signifyd_order_score, class_name: "SpreeSignifyd::OrderScore"

    scope :complete_and_approved, -> { complete.where.not(approved_at: nil) }

    prepend(InstanceMethods)
    singleton_class.prepend(PrependedClassMethods)
  end

  module PrependedClassMethods
    # temporary code. remove after the column is dropped from the db.
    def columns
      super.reject { |column| column.name == 'signifyd_score' }
    end
  end

  module InstanceMethods

    def is_risky?
      if signifyd_order_score
        signifyd_order_score.score <= SpreeSignifyd::Config[:signifyd_score_threshold]
      else
        true
      end
    end

    def approved_by(user)
      super

      shipments.each { |shipment| shipment.update!(self) }
      updater.update_shipment_state
      save
    end

  end
end

Spree::Order.include SpreeSignifyd::OrderDecorator
