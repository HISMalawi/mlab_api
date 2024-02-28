# frozen_string_literal: true

# Add columns to the table test results
class AddRemarksColumnToTestResults < ActiveRecord::Migration[7.0]
  def change
    add_column :test_results, :remarks, :text
  end
end
