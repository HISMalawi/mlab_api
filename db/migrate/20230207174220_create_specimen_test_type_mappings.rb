class CreateSpecimenTestTypeMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :specimen_test_type_mappings do |t|
      t.references :specimen, null: false, foreign_key: true
      t.references :test_type, null: false, foreign_key: true
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
