module SpreeSignifyd
  module ShipmentDecorator

    def determine_state(order)
      return 'pending' if pending? && !order.approved?
      super(order)
    end
  end
end

Spree::Shipment.prepend SpreeSignifyd::ShipmentDecorator
