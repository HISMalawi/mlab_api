class CreateStockOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_order_statuses do |t|
      t.references :stock_status, null: false, foreign_key: true
      t.references :stock_order, null: false, foreign_key: true
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :stock_order_statuses, :users, column: :creator, primary_key: :id
    add_foreign_key :stock_order_statuses, :users, column: :updated_by, primary_key: :id
    add_foreign_key :stock_order_statuses, :users, column: :voided_by, primary_key: :id
  end
end
