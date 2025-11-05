
# frozen_string_literal: true

# Migration to add codes to mlab tables
class AddColumnsToTestPanels < ActiveRecord::Migration[7.0]
  def change
    add_column :test_panels, :nlims_code, :string
    add_column :test_panels, :moh_code, :string
    add_column :test_panels, :loinc_code, :string
    add_column :test_panels, :scientific_name, :string
    add_column :test_panels, :preferred_name, :string
    add_column :test_panels, :short_name, :string unless TestPanel.column_names.include?('short_name')
    add_column :test_panels, :description, :string unless TestPanel.column_names.include?('description')
  end
end