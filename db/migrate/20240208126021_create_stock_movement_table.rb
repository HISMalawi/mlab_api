# frozen_string_literal: true

# stock movement statuses table
class CreateStockMovementTable < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_movements do |t|
      t.references :stock_transaction_type, null: false, foreign_key: true
      t.string :movement_to
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :stock_movements, :users, column: :creator, primary_key: :id
    add_foreign_key :stock_movements, :users, column: :updated_by, primary_key: :id
    add_foreign_key :stock_movements, :users, column: :voided_by, primary_key: :id
  end
end
