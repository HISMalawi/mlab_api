class CreateStockOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_order_statuses do |t|
      t.references :status, null: false, foreign_key: true
      t.references :stock_order, null: false, foreign_key: true
      t.bigint :creator
      t.timestamps
    end
  end
end
