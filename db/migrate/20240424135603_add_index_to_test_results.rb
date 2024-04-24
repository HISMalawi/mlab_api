# frozen_string_literal: true

# AddIndexToTestResults migration
class AddIndexToTestResults < ActiveRecord::Migration[7.0]
  def change
    add_index :test_results, %i[voided test_indicator_id test_id]
  end
end
