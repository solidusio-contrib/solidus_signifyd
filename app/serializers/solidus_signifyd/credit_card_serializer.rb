require 'active_model_serializers'

module SolidusSignifyd
  class CreditCardSerializer < ActiveModel::Serializer
    attributes :cardHolderName, :last4

    # this is how to conditionally include attributes in AMS
    def attributes(*args)
      hash = super
      hash[:expiryMonth] = object.month.to_i if object.month
      hash[:expiryYear] = object.year.to_i if object.year
      hash
    end

    def cardHolderName
      "#{SolidusSignifyd::Name.name_value(object)}"
    end

    def last4
      object.last_digits
    end
  end
end
