require 'active_model_serializers'

module SpreeSignifyd
  class DeliveryAddressSerializer < AddressSerializer
    def attributes
      hash = {}
      hash['deliveryAddress'] = address
      hash['fullName'] = object.full_name
      hash
    end
  end
end
