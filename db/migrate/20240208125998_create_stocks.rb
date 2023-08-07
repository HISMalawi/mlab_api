class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.references :stock_category, null: false, foreign_key: true
      t.references :stock_location, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.string :lot
      t.string :unit
      t.string :quantity
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.timestamps
    end
  end
end
