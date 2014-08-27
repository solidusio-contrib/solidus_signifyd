class SetConsideredRiskyDefaultValue < ActiveRecord::Migration
  def change
    change_column_default(:spree_orders, :considered_risky, true)
  end
end
