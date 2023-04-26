class CreateVisitTypeFacilitySectionMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :visit_type_facility_section_mappings do |t|
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :updated_date
      t.datetime :created_date

    end

    add_column :visit_type_facility_section_mappings, :facility_section_id, :bigint
    add_column :visit_type_facility_section_mappings, :visit_type_id, :bigint

    add_foreign_key :visit_type_facility_section_mappings, 
                    :facility_sections, column: :facility_section_id, primary_key: :id
    add_foreign_key :visit_type_facility_section_mappings, 
                    :visit_types, column: :visit_type_id, primary_key: :id 
                    
  end
end
