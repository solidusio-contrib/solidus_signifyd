class AddSignifydScoreToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :signifyd_score, :integer
  end
end
