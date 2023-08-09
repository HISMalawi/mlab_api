class CreateStockRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_requisitions, if_not_exists: true do |t|
      t.references :stock, null: false, foreign_key: true
      t.references :stock_order, null: false, foreign_key: true
      t.integer :quantity_requested
      t.integer :quantity_issued
      t.integer :quantity_collected
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.timestamps
    end
  end
end
