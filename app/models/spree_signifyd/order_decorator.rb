module SpreeSignifyd::OrderDecorator
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, do: :create_signifyd_case

    prepend(InstanceMethods)
  end

  module InstanceMethods

    def is_risky?
      return true if !signifyd_score
      signifyd_score < SpreeSignifyd::Config[:signifyd_score_threshold]
    end

    def approved_by(user)
      super
      update_shipments_after_approval
    end

    def signifyd_approve
      return if is_risky?

      update_attributes(
        considered_risky: false,
        approved_at: Time.now
      )
      update_shipments_after_approval
    end

    def create_signifyd_case
      SpreeSignifyd::CreateSignifydCase.perform(id)
    end

    def latest_payment
      payments.order("created_at DESC").first
    end

    private

    def update_shipments_after_approval
      shipments.each { |shipment| shipment.update!(self) }
      updater.update_shipment_state
      save
    end
  end
end

Spree::Order.include SpreeSignifyd::OrderDecorator
