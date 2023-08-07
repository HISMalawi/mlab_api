class CreateStockRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_requisitions do |t|
      t.string :quantity_requested
      t.string :quantity_issued
      t.string :quantity_collected
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.timestamps
    end
  end
end
