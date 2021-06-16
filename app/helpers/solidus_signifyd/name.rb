# frozen_string_literal: true

module SolidusSignifyd
  module Name
    def self.name_value(object)
      return object.name if SolidusSupport.combined_first_and_last_name_in_address? ||
                            object.is_a?(::Spree::CreditCard)

      object.full_name
    end
  end
end
