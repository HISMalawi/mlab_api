# frozen_string_literal: true

# Phase 1: Add UUID columns to all transactional tables
# This migration adds UUID columns without populating them yet (zero downtime)
class AddUuidToTransactionalTables < ActiveRecord::Migration[7.0]
  def change
    # Add UUID columns to primary tables
    add_column :orders, :uuid, :string, limit: 36, after: :id
    add_column :tests, :uuid, :string, limit: 36, after: :id
    add_column :order_statuses, :uuid, :string, limit: 36, after: :id
    add_column :test_statuses, :uuid, :string, limit: 36, after: :id
    add_column :test_results, :uuid, :string, limit: 36, after: :id

    # Add UUID foreign key columns for relationships
    # These will mirror the existing bigint foreign keys
    add_column :tests, :order_uuid, :string, limit: 36, after: :order_id
    add_column :order_statuses, :order_uuid, :string, limit: 36, after: :order_id
    add_column :test_statuses, :test_uuid, :string, limit: 36, after: :test_id
    add_column :test_results, :test_uuid, :string, limit: 36, after: :test_id
  end
end
