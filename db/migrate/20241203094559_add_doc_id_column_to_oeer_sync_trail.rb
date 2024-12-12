# frozen_string_literal: true

# Migration to add doc_id column to oeer_sync_trails table
class AddDocIdColumnToOeerSyncTrail < ActiveRecord::Migration[7.0]
  def change
    add_column :oerr_sync_trails, :doc_id, :string, null: true
  end
end
