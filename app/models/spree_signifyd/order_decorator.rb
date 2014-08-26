module SpreeSignifyd
  module OrderDecorator

    def is_risky?
      return true if !signifyd_score
      signifyd_score < SpreeSignifyd::Config[:signifyd_score_threshold]
    end

    def approved_by(user)
      super
      update_shipments
    end

    def signifyd_approve
      return if is_risky?

      update_attributes(
        considered_risky: false,
        approved_at: Time.now
      )
      update_shipments
    end

    private

    def update_shipments
      shipments.each { |shipment| shipment.update!(self) }
      updater.update_shipment_state
      save
    end
  end
end

Spree::Order.prepend SpreeSignifyd::OrderDecorator
