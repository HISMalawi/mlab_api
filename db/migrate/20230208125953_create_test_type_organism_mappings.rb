class CreateTestTypeOrganismMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :test_type_organism_mappings do |t|
      t.references :test_type, null: false, foreign_key: true
      t.references :organism, null: false, foreign_key: true
      t.bigint :creator
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.datetime :updated_date
      t.datetime :created_date

      t.timestamps
    end
  end
end
