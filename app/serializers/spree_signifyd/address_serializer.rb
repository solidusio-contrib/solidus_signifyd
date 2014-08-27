require 'active_model/serializer'

module SpreeSignifyd
  class AddressSerializer < ActiveModel::Serializer
    self.root = false

    attributes :address

    def address
      {
        'streetAddress' => object.address1,
        'unit' => object.address2,
        'city' => object.city,
        'provinceCode' => object.state.abbr,
        'postalCode' => object.zipcode,
        'countryCode' => object.country.iso
      }
    end
  end
end
