# frozen_string_literal: true

# This migration creates the catalog_versions table.
class CreateCatalogVersion < ActiveRecord::Migration[7.0]
  def change
    create_table :test_catalog_versions do |t|
      t.string :version
      t.json :version_details
      t.boolean :is_current, default: false
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :test_catalog_versions, :users, column: :creator, primary_key: :id
    add_foreign_key :test_catalog_versions, :users, column: :updated_by, primary_key: :id
    add_foreign_key :test_catalog_versions, :users, column: :voided_by, primary_key: :id
    add_index :test_catalog_versions, :version, unique: true
    add_index :test_catalog_versions, :creator
  end
end
