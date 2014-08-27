require 'active_model/serializer'

module SpreeSignifyd
  class LineItemSerializer < ActiveModel::Serializer
    self.root = false

    attributes :itemId, :itemName, :itemQuantity, :itemPrice

    def itemId
      object.variant_id
    end

    def itemName
      object.name
    end

    def itemQuantity
      object.quantity
    end

    def itemPrice
      object.price
    end
  end
end
