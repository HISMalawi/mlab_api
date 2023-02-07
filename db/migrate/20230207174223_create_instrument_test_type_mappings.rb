class CreateInstrumentTestTypeMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :instrument_test_type_mappings do |t|
      t.references :instrument, null: false, foreign_key: true
      t.references :test_type, null: false, foreign_key: true
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
