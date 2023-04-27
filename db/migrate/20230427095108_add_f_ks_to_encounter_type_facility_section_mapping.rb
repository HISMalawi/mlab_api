class AddFKsToEncounterTypeFacilitySectionMapping < ActiveRecord::Migration[7.0]
  def change
    add_column :encounter_type_facility_section_mappings, :facility_section_id, :bigint, null: false
    add_foreign_key :encounter_type_facility_section_mappings, :facility_sections, column: :facility_section_id, primary_key: :id
    add_column :encounter_type_facility_section_mappings, :encounter_type_id, :bigint, null: false
    add_foreign_key :encounter_type_facility_section_mappings, :encounter_types, column: :encounter_type_id, primary_key: :id
  end
end
