require 'active_model/serializer'

module SpreeSignifyd
  class DeliveryAddressSerializer < AddressSerializer
    self.root = false

    def attributes
      hash = {}
      hash['deliveryAddress'] = address
      hash['fullName'] = object.full_name
      hash
    end
  end
end
