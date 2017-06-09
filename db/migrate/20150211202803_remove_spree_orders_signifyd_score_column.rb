class RemoveSpreeOrdersSignifydScoreColumn < SolidusSupport::Migration[4.2]
  def change
    remove_column :spree_orders, :signifyd_score, :integer
  end
end
