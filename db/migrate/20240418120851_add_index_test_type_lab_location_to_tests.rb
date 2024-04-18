# frozen_string_literal: true

# AddIndexTestTypeLabLocationToTests migration
class AddIndexTestTypeLabLocationToTests < ActiveRecord::Migration[7.0]
  def change
    add_index :tests, %i[test_type_id lab_location_id]
    add_index :tests, %i[status_id lab_location_id]
  end
end
