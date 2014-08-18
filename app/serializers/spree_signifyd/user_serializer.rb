require 'active_model/serializer'

module SpreeSignifyd
  class UserSerializer < ActiveModel::Serializer
    self.root = false

    attributes :emailAddress, :username, :createdDate, :lastUpdateDate

    def emailAddress
      object.email
    end

    def username
      object.email
    end

    def createdDate
      object.created_at.utc.iso8601
    end

    def lastUpdateDate
      object.updated_at.utc.iso8601
    end
  end
end
