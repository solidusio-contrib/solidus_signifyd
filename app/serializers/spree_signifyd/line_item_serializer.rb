require 'active_model_serializers'

module SpreeSignifyd
  class LineItemSerializer < ActiveModel::Serializer
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
