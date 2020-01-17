module SolidusSignifyd
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.include SolidusSignifyd::OrderConcerns
      end

      ::Spree::Order.prepend self
    end
  end
end
