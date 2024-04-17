# frozen_string_literal: true

# Add index voided lab location to tests
class AddIndexVoidedLabLocationToTests < ActiveRecord::Migration[7.0]
  def change
    add_index :tests, %i[voided lab_location_id]
  end
end
