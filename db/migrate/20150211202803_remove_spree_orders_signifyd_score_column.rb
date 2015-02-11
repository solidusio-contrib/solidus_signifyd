class RemoveSpreeOrdersSignifydScoreColumn < ActiveRecord::Migration
  def change
    remove_column :spree_orders, :signifyd_score, :integer
  end
end
