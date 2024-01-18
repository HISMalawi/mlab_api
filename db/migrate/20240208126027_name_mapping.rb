# frozen_string_literal: true

# NameMapping statuses table
class NameMapping < ActiveRecord::Migration[7.0]
  def change
    create_table :name_mapping do |t|
      t.string :actual_name
      t.string :manual_name
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :name_mapping, :users, column: :creator, primary_key: :id
    add_foreign_key :name_mapping, :users, column: :updated_by, primary_key: :id
    add_foreign_key :name_mapping, :users, column: :voided_by, primary_key: :id
  end
end
