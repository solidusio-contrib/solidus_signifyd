class TransferSpreeOrdersSignifydScoreData < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    Spree::Order.connection.execute(<<-SQL)
      insert into spree_signifyd_order_scores (order_id, score, created_at, updated_at)
      select o.id, o.signifyd_score, '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}'
      from spree_orders o
      left join spree_signifyd_order_scores
        on o.id = spree_signifyd_order_scores.order_id
      where o.signifyd_score is not null -- where the order has a score...
      and spree_signifyd_order_scores.id is null -- ...but the new table does not
    SQL
  end
end
