require 'spree_core'
require 'signifyd'
require 'spree_signifyd/create_signifyd_case'
require 'spree_signifyd/engine'
require 'spree_signifyd/request_verifier'
require 'resque'

module SpreeSignifyd
  class DefaultApproverNotFound < StandardError; end

  module_function

  def set_score(order:, score:)
    if order.signifyd_order_score
      order.signifyd_order_score.update!(score: score)
    else
      order.create_signifyd_order_score!(score: score)
    end
  end

  def approve(order:)
    if default_approver = Spree::User.find_by(email: SpreeSignifyd::Config[:default_approver_email])
      order.approved_by(default_approver)
    else
      raise DefaultApproverNotFound, "Cannot approve order. email=#{SpreeSignifyd::Config[:default_approver_email].inspect}"
    end
  end

  def create_case(order_id:)
    Resque.enqueue(SpreeSignifyd::CreateSignifydCase, order_id)
  end

end
