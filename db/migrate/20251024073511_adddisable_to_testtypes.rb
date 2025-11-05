# frozen_string_literal: true

# This migration adds a new column `disable` to the `test_types` table
class AdddisableToTesttypes < ActiveRecord::Migration[7.0]
  def change
    add_column :test_types, :disabled, :boolean, default: false unless column_exists?(:test_types, :disable)
    add_index :test_types, :disabled unless index_exists?(:test_types, :disable)
  end
end
