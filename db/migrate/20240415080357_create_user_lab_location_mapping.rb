# frozen_string_literal: true

# CreateUserLabLocationMapping migration
class CreateUserLabLocationMapping < ActiveRecord::Migration[7.0]
  def change
    create_table :user_lab_location_mappings do |t|
      t.bigint :user_id
      t.bigint :lab_location_id
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :user_lab_location_mappings, :users, column: :creator, primary_key: :id
    add_foreign_key :user_lab_location_mappings, :users, column: :updated_by, primary_key: :id
    add_foreign_key :user_lab_location_mappings, :users, column: :voided_by, primary_key: :id
  end
end
