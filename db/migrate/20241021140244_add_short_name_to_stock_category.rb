class AddShortNameToStockCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_categories, :short_name, :string, null: true
  end
end
