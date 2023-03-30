class CreateDrugOrganismMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :drug_organism_mappings do |t|
      t.references :drug, null: false, foreign_key: true
      t.references :organism, null: false, foreign_key: true
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :updated_date
      t.datetime :created_date

      
    end
  end
end
