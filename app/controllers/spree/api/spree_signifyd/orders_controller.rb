module Spree::Api::SpreeSignifyd
  class OrdersController < ActionController::Base
    include SpreeSignifyd::RequestVerifier

    respond_to :json

    before_action :authorize, :load_order, :order_canceled_or_shipped

    def update
      SpreeSignifyd.set_score(order: @order, score: score)
      SpreeSignifyd.set_case_id(order: @order, case_id: case_id)

      if is_fraudulent?
        @order.cancel!
      elsif should_approve?
        SpreeSignifyd.approve(order: @order)
      end

      head 200
    end

    private

    def authorize
      request_sha = request.headers['HTTP_X_SIGNIFYD_SEC_HMAC_SHA256']
      computed_sha = build_sha(SpreeSignifyd::Config[:api_key], request.raw_post)

      if !Devise.secure_compare(request_sha, computed_sha)
        logger.error("computed digest does not match provided digest. computed=#{computed_sha.inspect} provided=#{request_sha.inspect}")
        logger.info("content-type header: #{request.headers["Content-Type"].inspect}")
        logger.info("raw_post bytes: #{request.raw_post.bytes}")
        head 401
      end
    end

    def load_order
      head 404 unless @order = Spree::Order.find_by(number: body['orderId'])
    end

    def order_canceled_or_shipped
      head 200 if @order.shipped? || @order.canceled?
    end

    def body
      @body ||= JSON.parse(request.raw_post)
    end

    def is_fraudulent?
      body['reviewDisposition'] == 'FRAUDULENT'
    end

    def should_approve?
      body['reviewDisposition'] == 'GOOD' || SpreeSignifyd.score_above_threshold?(score)
    end

    def score
      body['adjustedScore']
    end

    def case_id
      body['caseId']
    end
  end
end
