module SpreeSignifyd
  class CreateSignifydCase < ActiveJob::Base
    queue_as :default

    def perform(order_number_or_id)
      Rails.logger.info "Processing Signifyd case creation event: #{order_number_or_id}"
      order = Spree::Order.find_by(number: order_number_or_id) || Spree::Order.find(order_number_or_id)
      order_data = JSON.parse(OrderSerializer.new(order).to_json)
      Rails.logger.info "Order data sent to Signifyd for order #{order.number}: #{order_data}"
      Signifyd::Case.create(order_data, SpreeSignifyd::Config[:api_key])
    end
  end
end
