# frozen_string_literal: true

# Add status id to orders and tests table migration
class AddStatusIdToOrdersAndTests < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :status_id, :bigint, foreign_key: true, default: 9
    add_column :tests, :status_id, :bigint, foreign_key: true, default: 2
    add_index :orders, :status_id
    add_index :tests, :status_id
    add_foreign_key :orders, :statuses, column: :status_id, primary_key: :id
    add_foreign_key :tests, :statuses, column: :status_id, primary_key: :id
  end
end
