class AddFkToEncounters < ActiveRecord::Migration[7.0]
  def change
    add_column :encounters, :encounter_type_id, :bigint
    add_foreign_key :encounters, :encounter_types, column: :encounter_type_id
  end
end
