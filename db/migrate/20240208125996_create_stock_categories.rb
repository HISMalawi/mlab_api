class CreateStockCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_categories do |t|
      t.string :name
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.timestamps
    end
  end
end
