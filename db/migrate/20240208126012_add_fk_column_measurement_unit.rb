class AddFkColumnMeasurementUnit < ActiveRecord::Migration[7.0]
  def change
  end
  add_foreign_key :stock_items, :stock_units, column: :measurement_unit, primary_key: :id
end
