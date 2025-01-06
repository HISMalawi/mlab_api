# frozen_string_literal: true

# AddTestTypeIdToOerrTrail migration
class AddTestTypeIdToOerrTrail < ActiveRecord::Migration[7.0]
  def change
    add_column :oerr_sync_trails, :test_type_id, :bigint, null: true
  end
end
