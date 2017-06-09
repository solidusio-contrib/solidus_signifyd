class AddCaseIdToSpreeSignifydOrderScores < SolidusSupport::Migration[4.2]
  def up
    add_column :spree_signifyd_order_scores, :case_id, :integer
  end

  def down
    remove_column :spree_signifyd_order_scores, :case_id
  end
end
