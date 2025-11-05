# frozen_string_literal: true

# Machine Results migration
class CreateMachineResults < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:machine_results)

    create_table :machine_results do |t|
      t.integer :indicator_id
      t.string :value
      t.string :machine_name
      t.string :indicator_name
      t.string :tracking_number

      t.timestamps
    end
    add_index :machine_results, [:indicator_id, :tracking_number], unique: true
    add_index :machine_results, :machine_name
  end
end
