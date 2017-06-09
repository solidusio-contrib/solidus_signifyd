class CreateSpreeSignifydOrderScores < SolidusSupport::Migration[4.2]
  def change
    create_table :spree_signifyd_order_scores do |t|
      t.integer :order_id
      t.integer :score
      t.timestamps null: true
    end

    add_index :spree_signifyd_order_scores, :order_id, unique: true
  end
end
