# frozen_string_literal: true

# Migration to add codes to mlab tables
class AddCodesToMlabTables < ActiveRecord::Migration[7.0]
  def change
    add_column :test_types, :nlims_code, :string
    add_column :test_types, :moh_code, :string
    add_column :test_types, :loinc_code, :string
    add_column :test_types, :scientific_name, :string
    add_column :test_types, :preferred_name, :string
    add_column :test_types, :short_name, :string unless TestType.column_names.include?('short_name')
    add_column :test_types, :description, :string unless TestType.column_names.include?('description')

    add_column :departments, :nlims_code, :string
    add_column :departments, :moh_code, :string
    add_column :departments, :loinc_code, :string
    add_column :departments, :scientific_name, :string
    add_column :departments, :preferred_name, :string
    add_column :departments, :short_name, :string unless Department.column_names.include?('short_name')
    add_column :departments, :description, :string unless Department.column_names.include?('description')

    add_column :drugs, :nlims_code, :string
    add_column :drugs, :moh_code, :string
    add_column :drugs, :loinc_code, :string
    add_column :drugs, :scientific_name, :string
    add_column :drugs, :preferred_name, :string
    add_column :drugs, :short_name, :string unless Drug.column_names.include?('short_name')
    add_column :drugs, :description, :string unless Drug.column_names.include?('description')

    add_column :organisms, :nlims_code, :string
    add_column :organisms, :moh_code, :string
    add_column :organisms, :loinc_code, :string
    add_column :organisms, :scientific_name, :string
    add_column :organisms, :preferred_name, :string
    add_column :organisms, :short_name, :string unless Organism.column_names.include?('short_name')
    add_column :organisms, :description, :string unless Organism.column_names.include?('description')

    add_column :specimen, :nlims_code, :string
    add_column :specimen, :moh_code, :string
    add_column :specimen, :loinc_code, :string
    add_column :specimen, :scientific_name, :string
    add_column :specimen, :preferred_name, :string
    add_column :specimen, :short_name, :string unless Specimen.column_names.include?('short_name')
    add_column :specimen, :description, :string unless Specimen.column_names.include?('description')

    add_column :test_indicators, :nlims_code, :string
    add_column :test_indicators, :moh_code, :string
    add_column :test_indicators, :loinc_code, :string
    add_column :test_indicators, :scientific_name, :string
    add_column :test_indicators, :preferred_name, :string
    add_column :test_indicators, :short_name, :string unless TestIndicator.column_names.include?('short_name')
    add_column :test_indicators, :description, :string unless TestIndicator.column_names.include?('description')
  end
end
