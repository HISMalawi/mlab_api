# frozen_string_literal: true

# Migration to add drop column to test_indicators
class AddDropColumnFromTestIndicators < ActiveRecord::Migration[7.0]
  def change
    remove_column :test_indicators, :test_indicator_type, :integer
    remove_column :test_indicators, :unit, :string
    remove_column :test_indicators, :test_type_id, :integer
    add_column :test_type_indicator_mappings, :test_indicator_type, :integer
    add_column :test_type_indicator_mappings, :unit, :string
  end
end
