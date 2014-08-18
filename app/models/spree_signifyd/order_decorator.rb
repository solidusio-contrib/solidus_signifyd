module SpreeSignifyd
  module OrderDecorator

    def is_risky?
      return true if !signifyd_score
      signifyd_score < SpreeSignifyd::Config[:signifyd_score_threshold]
    end

    def approved_by(user)
      super
      shipments.each { |shipment| shipment.update!(self) }
      updater.update_shipment_state
      save
    end
  end
end

Spree::Order.prepend SpreeSignifyd::OrderDecorator
