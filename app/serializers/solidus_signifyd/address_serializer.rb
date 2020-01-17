require 'active_model_serializers'

module SolidusSignifyd
  class AddressSerializer < ActiveModel::Serializer
    attributes :address

    def address
      {
        'streetAddress' => object.address1,
        'unit' => object.address2,
        'city' => object.city,
        'provinceCode' => object.state_text,
        'postalCode' => object.zipcode,
        'countryCode' => object.country.iso
      }
    end
  end
end
