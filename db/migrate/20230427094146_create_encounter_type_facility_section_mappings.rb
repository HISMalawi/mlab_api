class CreateEncounterTypeFacilitySectionMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :encounter_type_facility_section_mappings do |t|
      t.bigint :creator
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.datetime :created_date
      t.datetime :updated_by
      t.datetime :updated_date

      add_foreign_key :encounter_type_facility_section_mappings, :users, column: :creator, primary_key: :id
    end
  end
end
