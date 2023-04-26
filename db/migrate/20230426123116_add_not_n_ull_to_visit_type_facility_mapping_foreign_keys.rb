class AddNotNUllToVisitTypeFacilityMappingForeignKeys < ActiveRecord::Migration[7.0]
  def change
    change_column :visit_type_facility_section_mappings, :facility_section_id, :bigint, null: false
    change_column :visit_type_facility_section_mappings, :visit_type_id, :bigint, null: false
  end
end
