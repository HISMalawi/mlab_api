class AddPrintDeviceColumnToTestType < ActiveRecord::Migration[7.0]
  def change
    add_column :test_types, :print_device, :boolean
  end
end
