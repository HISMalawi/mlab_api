class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.references :stock_item, null: false, foreign_key: true
      t.references :stock_location, null: false, foreign_key: true
      t.integer :quantity
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.datetime :updated_by, null: true
    end
    add_foreign_key :stocks, :users, column: :creator, primary_key: :id
    add_foreign_key :stocks, :users, column: :updated_by, primary_key: :id
    add_foreign_key :stocks, :users, column: :voided_by, primary_key: :id
  end
end
