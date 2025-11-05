# frozen_string_literal: true

# This migration creates the test_type_lab_test_sites table.
class TestTypeLabsites < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:test_type_lab_test_sites)

    create_table :test_type_lab_test_sites do |t|
      t.references :test_type, null: false, foreign_key: true
      t.references :lab_test_site, null: false, foreign_key: true
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :test_type_lab_test_sites, :users, column: :creator, primary_key: :id
    add_foreign_key :test_type_lab_test_sites, :users, column: :updated_by, primary_key: :id
    add_foreign_key :test_type_lab_test_sites, :users, column: :voided_by, primary_key: :id
    add_index :test_type_lab_test_sites, %i[test_type_id lab_test_site_id], unique: true,
                                                                            name: 'index_test_type_and_lab_test_site'
  end
end
