# frozen_string_literal: true

# This migration updates the description column of the test_types table to be of type text
class UpdateTestTypeDescriptionColumnToText < ActiveRecord::Migration[7.0]
  def change
    change_column :test_types, :description, :text
  end
end
