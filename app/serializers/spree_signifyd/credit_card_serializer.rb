require 'active_model_serializers'

module SpreeSignifyd
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
      "#{object.first_name} #{object.last_name}"
    end

    def last4
      object.last_digits
    end
  end
end
