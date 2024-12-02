# frozen_string_literal: true

# This oerr sync trail migration
class CreateOerrSyncTrail < ActiveRecord::Migration[7.0]
  def change
    create_table :oerr_sync_trails do |t|
      t.bigint :order_id, null: false
      t.bigint :test_id, null: false
      t.string :npid, null: true
      t.bigint :facility_section_id, null: true
      t.string :requested_by, null: true
      t.datetime :sample_collected_time, null: true
      t.boolean :synced, null: false, default: false
      t.datetime :synced_at, null: true
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_index :oerr_sync_trails, %i[id order_id], unique: true
    add_index :oerr_sync_trails, %i[id test_id], unique: true
    add_index :oerr_sync_trails, :id, unique: true
    add_foreign_key :oerr_sync_trails, :users, column: :creator, primary_key: :id
    add_foreign_key :oerr_sync_trails, :users, column: :updated_by, primary_key: :id
    add_foreign_key :oerr_sync_trails, :users, column: :voided_by, primary_key: :id
  end
end
