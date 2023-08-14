class ChangeColumnMeasurementUnit < ActiveRecord::Migration[7.0]
  def change
    change_column :stock_items, :measurement_unit, :bigint
  end
end
