# frozen_string_literal: true

# test type indicator table
class CreateTestTypeIndicatorMapping < ActiveRecord::Migration[7.0]
  def change
    create_table :test_type_indicator_mappings do |t|
      t.references :test_types, null: false, foreign_key: true
      t.references :test_indicators, null: false, foreign_key: true
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :test_type_indicator_mappings, :users, column: :creator, primary_key: :id
    add_foreign_key :test_type_indicator_mappings, :users, column: :updated_by, primary_key: :id
    add_foreign_key :test_type_indicator_mappings, :users, column: :voided_by, primary_key: :id
  end
end
