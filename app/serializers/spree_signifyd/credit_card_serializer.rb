require 'active_model/serializer'

module SpreeSignifyd
  class CreditCardSerializer < ActiveModel::Serializer
    self.root = false

    attributes :cardHolderName, :last4, :expiryMonth, :expiryYear

    def cardHolderName
      "#{object.first_name} #{object.last_name}"
    end

    def last4
      object.last_digits
    end

    def expiryMonth
      object.month
    end

    def expiryYear
      object.year
    end
  end
end
