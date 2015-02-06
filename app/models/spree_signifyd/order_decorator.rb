module SpreeSignifyd::OrderDecorator
  extend ActiveSupport::Concern

  included do
    Spree::Order.state_machine.after_transition to: :complete, do: :create_signifyd_case
    scope :complete_and_approved, -> { complete.where.not(approved_at: nil) }
    has_one :signifyd_order_score, class_name: "SpreeSignifyd::OrderScore"

    prepend(InstanceMethods)
  end

  module InstanceMethods

    def is_risky?
      return true if !signifyd_score
      signifyd_score <= SpreeSignifyd::Config[:signifyd_score_threshold]
    end

    def approved_by(user)
      super
      update_shipments_after_approval
    end

    def signifyd_approve
      default_approver = Spree::User.find_by(email: SpreeSignifyd::Config[:default_approver_email])
      raise 'No user was found for the default_approver_email preference. Cannot approve order.' if default_approver.blank?
      approved_by(default_approver)
    end

    def create_signifyd_case
      Resque.enqueue(SpreeSignifyd::CreateSignifydCase, id)
    end

    def latest_payment
      payments.order("created_at DESC").first
    end

    def signifyd_score
      signifyd_order_score.try(:score) || attributes['signifyd_score']
    end

    def set_signifyd_score(score)
      if signifyd_order_score
        signifyd_order_score.update!(score: score)
      else
        create_signifyd_order_score!(score: score)
      end
      update_columns(signifyd_score: score)
    end

    def signifyd_score=(score)
      raise "Scores should be set through signifyd_order_score"
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
