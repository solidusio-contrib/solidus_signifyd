require 'active_model_serializers'

module SpreeSignifyd
  class UserSerializer < ActiveModel::Serializer
    attributes :emailAddress, :username, :createdDate, :lastUpdateDate, :aggregateOrderCount, :aggregateOrderDollars, :phone

    # this is how to conditionally include attributes in AMS
    def attributes(*args)
      hash = super
      hash[:lastOrderId] = lastOrderId if lastOrderId.present?
      hash
    end

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

    def lastOrderId
      completed_orders.order("completed_at DESC").second.try(:number)
    end

    def aggregateOrderCount
      completed_orders.count
    end

    def aggregateOrderDollars
      completed_orders.sum(:total).to_f
    end

    def phone
      object.orders.order("created_at DESC").first.try!(:ship_address).try!(:phone)
    end

    private

    def completed_orders
      @order ||= object.orders.complete
    end

  end
end
