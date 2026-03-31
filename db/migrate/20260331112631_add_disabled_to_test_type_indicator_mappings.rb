# frozen_string_literal: true

# Migration to add disabled column to test_type_indicator_mappings table
class AddDisabledToTestTypeIndicatorMappings < ActiveRecord::Migration[7.0]
  def change
    add_column :test_type_indicator_mappings, :disabled, :integer, default: 0, if_not_exists: true
  end
end
