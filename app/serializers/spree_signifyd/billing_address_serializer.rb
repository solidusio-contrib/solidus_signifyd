require 'active_model/serializer'

module SpreeSignifyd
  class BillingAddressSerializer < AddressSerializer
    self.root = false

    def attributes
      hash = {}
      hash['billingAddress'] = address
      hash
    end
  end
end
