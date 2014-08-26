module Spree::Api::SpreeSignifyd
  class OrdersController < Spree::Api::BaseController
    include SpreeSignifyd::RequestVerifier

    def update
      if !valid_header_sha?
        status = 401
      elsif !order
        status = 404
      else
        status = 200
        order.update_attributes!(signifyd_score: params['score'])
        order.signifyd_approve
      end

      render nothing: true, status: status
    end

    private

    def order
      @order ||= Spree::Order.find_by(number: params['orderId'])
    end

    def valid_header_sha?
      request_sha = request.headers['HTTP_X_SIGNIFYD_HMAC_SHA256']
      computed_sha = build_sha(SpreeSignifyd::Config[:api_key], request.raw_post)
      request_sha == computed_sha
    end
  end
end
