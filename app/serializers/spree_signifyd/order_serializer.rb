require 'active_model/serializer'

module SpreeSignifyd
  class OrderSerializer < ActiveModel::Serializer
    self.root = false

    attributes :purchase, :recipient
    has_one :user, serializer: SpreeSignifyd::UserSerializer, root: "userAccount"

    def purchase
      {
        'browserIpAddress' => object.last_ip_address,
        'orderId' => object.number,
        'createdAt' => object.completed_at.utc.iso8601,
        'currency' => object.currency,
        'totalPrice' => object.total
      }
    end

    def recipient
      recipient = SpreeSignifyd::AddressSerializer.new(object.ship_address).serializable_object
      recipient[:confirmationEmail] = object.email
      recipient
    end
  end
end
