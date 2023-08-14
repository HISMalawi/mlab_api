class CreateStockTransactionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_transaction_types do |t|
      t.string :name
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.datetime :updated_by, null: true
    end
    add_foreign_key :stock_transaction_types, :users, column: :creator, primary_key: :id
    add_foreign_key :stock_transaction_types, :users, column: :updated_by, primary_key: :id
    add_foreign_key :stock_transaction_types, :users, column: :voided_by, primary_key: :id
  end
end
