require 'spree_core'
require 'signifyd'
require 'spree_signifyd/create_signifyd_case'
require 'spree_signifyd/engine'
require 'spree_signifyd/request_verifier'
require 'resque'
require 'devise'

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
    order.shipments.each { |shipment| shipment.ready! if shipment.pending? }
    order.updater.update_shipment_state
    order.save!
  end

  def create_case(order_number:)
    Rails.logger.info "Queuing Signifyd case creation event: #{order_number}"
    SpreeSignifyd::CreateSignifydCase.perform_later(order_number)
  end

  def score_above_threshold?(score)
    score > SpreeSignifyd::Config[:signifyd_score_threshold]
  end

end
