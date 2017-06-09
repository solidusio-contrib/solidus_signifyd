class AddSignifydScoreToOrders < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_orders, :signifyd_score, :integer
  end
end
