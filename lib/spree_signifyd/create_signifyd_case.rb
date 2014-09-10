module SpreeSignifyd
  class CreateSignifydCase
    @queue = :spree_backend_high

    def self.perform(order_id)
      order = Spree::Order.find(order_id)
      order_data = JSON.parse(OrderSerializer.new(order).to_json)
      Signifyd::Case.create(order_data, SpreeSignifyd::Config[:api_key])
    end

  end
end
