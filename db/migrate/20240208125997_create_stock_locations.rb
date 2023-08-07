class CreateStockLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_locations do |t|
      t.string :name
      t.string :description
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.timestamps
    end
  end
end
