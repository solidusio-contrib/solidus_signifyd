class SetConsideredRiskyDefaultValue < ActiveRecord::Migration
  def change
    change_column_default(:spree_orders, :considered_risky, true) if Spree::Order.column_names.include? "considered_risky"
  end
end
