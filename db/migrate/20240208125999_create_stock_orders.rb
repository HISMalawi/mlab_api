class CreateStockOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_orders do |t|
      t.string :identifier
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.timestamps
    end
  end
end
