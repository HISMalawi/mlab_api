# frozen_string_literal: true

# Creates ward_change_trails table to track ward movements for encounters
class CreateWardChangeTrails < ActiveRecord::Migration[7.0]
  def change
    create_table :ward_change_trails do |t|
      t.references :encounter, null: false, foreign_key: true
      t.references :previous_facility_section, foreign_key: { to_table: :facility_sections }, null: true
      t.references :new_facility_section, foreign_key: { to_table: :facility_sections }, null: false
      t.string :changed_by_name
      t.bigint :changed_by, null: false
      t.datetime :changed_at, null: false
      t.text :reason
      t.integer :voided, default: 0
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by

      t.timestamps
    end

    add_index :ward_change_trails, :changed_at
    add_index :ward_change_trails, %i[encounter_id voided]
  end
end
