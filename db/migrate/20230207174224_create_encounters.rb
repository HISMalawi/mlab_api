class CreateEncounters < ActiveRecord::Migration[7.0]
  def change
    create_table :encounters do |t|
      t.references :client, null: false, foreign_key: true
      t.references :facility, null: false, foreign_key: true
      t.references :destination, null: false
      t.references :facility_section, null: false, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.string :uuid

      
    end
  end
end
