# frozen_string_literal: true

# migration to add indexes to the tests table
class AddIndexVoidedToTests < ActiveRecord::Migration[7.0]
  def change
    add_index :tests, %i[voided status_id]
    add_index :tests, %i[voided created_date]
  end
end
