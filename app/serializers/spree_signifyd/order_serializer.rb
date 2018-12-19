require 'active_model_serializers'

module SpreeSignifyd
  class OrderSerializer < ActiveModel::Serializer
    attributes :purchase, :recipient, :card, :userAccount

    def purchase
      build_purchase_information.tap do |purchase_info|
        if paid_by_paypal?
          purchase_info["paymentGateway"] = "paypal_account"
        end
      end
    end

    def recipient
      recipient = SpreeSignifyd::DeliveryAddressSerializer.new(object.ship_address).serializable_hash
      recipient[:confirmationEmail] = object.email
      recipient[:fullName] = object.ship_address.full_name
      recipient
    end

    def card
      payment_source = latest_payment.try(:source)
      card = {}

      if payment_source.present? && payment_source.instance_of?(Spree::CreditCard)
        card = CreditCardSerializer.new(payment_source).serializable_hash
        card.merge!(SpreeSignifyd::BillingAddressSerializer.new(object.bill_address).serializable_hash)
      end

      card
    end

    def userAccount
      return {} unless object.user
      UserSerializer.new(object.user).serializable_hash
    end

    private

    def paid_by_paypal?
      latest_payment.try!(:source).try(:cc_type) == "paypal"
    end

    def build_purchase_information
      {
        'browserIpAddress' => object.last_ip_address || "",
        'orderId' => object.number,
        'createdAt' => object.completed_at.utc.iso8601,
        'currency' => object.currency,
        'totalPrice' => object.total.to_f,
        'products' => products,
        'avsResponseCode' => latest_payment.try!(:avs_response) || "",
        'cvvResponseCode' => latest_payment.try!(:cvv_response_code) || ""
      }
    end

    def products
      order_products = []

      object.line_items.each do |li|
        serialized_line_item = SpreeSignifyd::LineItemSerializer.new(li).serializable_hash
        order_products << serialized_line_item
      end

      order_products
    end

    def latest_payment
      object.payments.order(:created_at, :id).last
    end
  end
end
