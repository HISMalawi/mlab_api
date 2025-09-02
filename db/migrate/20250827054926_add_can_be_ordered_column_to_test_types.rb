# frozen_string_literal: true

# This migration adds a new column `can_be_ordered` to the `test_types` table
class AddCanBeOrderedColumnToTestTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :test_types, :can_be_ordered, :boolean, default: false
    add_index :test_types, :can_be_ordered
  end
end
