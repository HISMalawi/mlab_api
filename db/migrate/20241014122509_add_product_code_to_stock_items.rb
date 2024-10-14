class AddProductCodeToStockItems < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_items, :product_code, :string, null: true
  end
end
