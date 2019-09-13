module SpreeSignifyd
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.include SpreeSignifyd::OrderConcerns
      end

      ::Spree::Order.prepend self
    end
  end
end
