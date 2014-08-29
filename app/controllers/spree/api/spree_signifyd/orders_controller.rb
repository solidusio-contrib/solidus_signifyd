module Spree::Api::SpreeSignifyd
  class OrdersController < ActionController::Base
    include SpreeSignifyd::RequestVerifier

    respond_to :json

    before_filter :authorize, :load_order, :order_canceled_or_shipped

    def update
      @order.update_attributes!(signifyd_score: body['adjustedScore'])

      if is_fraudulent?
        @order.cancel!
      elsif should_approve?
        @order.signifyd_approve
      end

      render nothing: true, status: 200
    end

    private

    def authorize
      request_sha = request.headers['HTTP_HTTP_X_SIGNIFYD_HMAC_SHA256']
      computed_sha = build_sha(SpreeSignifyd::Config[:api_key], request.raw_post)

      if request_sha != computed_sha
        render(nothing: true, status: 401) and return false
      end
    end

    def load_order
      @order = Spree::Order.find_by(number: body['orderId'])

      if !@order
        render(nothing: true, status: 404) and return false
      end
    end

    def order_canceled_or_shipped
      if @order.shipped?
        raise "Attempting to approve/deny order ##{@order.number} via Signifyd, but it has already been shipped"
      elsif @order.canceled?
        raise "Attempting to approve/deny order ##{@order.number} via Signifyd, but it has already been canceled"
      end
    end

    def body
      @body ||= JSON.parse(request.raw_post)
    end

    def is_fraudulent?
      body['reviewDisposition'] == 'FRAUDULENT'
    end

    def should_approve?
      !@order.approved? && (body['reviewDisposition'] == 'GOOD' || !@order.is_risky?)
    end
  end
end
