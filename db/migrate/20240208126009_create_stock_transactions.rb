class CreateStockTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_transactions do |t|
      t.references :stock, null: false, foreign_key: true
      t.references :stock_transaction_type, null: false, foreign_key: true
      t.string :lot
      t.string :batch
      t.integer :quantity
      t.datetime :expiry_date
      t.string :receiving_from
      t.string :sending_to
      t.integer :received_by
      t.string :optional_receiver
      t.text :remarks
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.datetime :updated_by, null: true
    end
    add_foreign_key :stock_transactions, :users, column: :creator, primary_key: :id
    add_foreign_key :stock_transactions, :users, column: :updated_by, primary_key: :id
    add_foreign_key :stock_transactions, :users, column: :voided_by, primary_key: :id
    add_foreign_key :stock_transactions, :users, column: :received_by, primary_key: :id
  end
end
