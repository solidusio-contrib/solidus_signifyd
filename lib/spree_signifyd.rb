require 'spree_core'
require 'signifyd'
require 'spree_signifyd/create_signifyd_case'
require 'spree_signifyd/engine'
require 'spree_signifyd/request_verifier'
require 'resque'

module SpreeSignifyd

  module_function

  def set_score(order:, score:)
    if order.signifyd_order_score
      order.signifyd_order_score.update!(score: score)
    else
      order.create_signifyd_order_score!(score: score)
    end
  end

  def approve(order:)
    order.contents.approve(name: self.name)
    order.shipments.each { |shipment| shipment.update!(order) }
    order.updater.update_shipment_state
    order.save!
  end

  def create_case(order_id:)
    Resque.enqueue(SpreeSignifyd::CreateSignifydCase, order_id)
  end

end
