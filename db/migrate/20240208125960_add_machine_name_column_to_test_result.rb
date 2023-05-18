class AddMachineNameColumnToTestResult < ActiveRecord::Migration[7.0]
  def change
    add_column :test_results, :machine_name, :string
  end
end
