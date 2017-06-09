class SetConsideredRiskyDefaultValue < SolidusSupport::Migration[4.2]
  def change
    change_column_default(:spree_orders, :considered_risky, true) if Spree::Order.column_names.include? "considered_risky"
  end
end
