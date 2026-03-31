
# frozen_string_literal: true

# This migration creates the catalog sync trail table.
class CatalogSyncTrail < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:test_catalog_sync_trails)

    create_table :test_catalog_sync_trails do |t|
      t.string :version
      t.string :section
      t.boolean :synced, default: false
      t.datetime :synced_at, default: Time.now
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :test_catalog_sync_trails, :users, column: :creator, primary_key: :id
    add_foreign_key :test_catalog_sync_trails, :users, column: :updated_by, primary_key: :id
    add_foreign_key :test_catalog_sync_trails, :users, column: :voided_by, primary_key: :id
    add_index :test_catalog_sync_trails, :version, unique: true
    add_index :test_catalog_sync_trails, :creator
  end
end