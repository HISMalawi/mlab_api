class AddTestTypeToTestIndictorRanges < ActiveRecord::Migration[7.0]
  def change
    add_reference :test_indicator_ranges, :test_type, foreign_key: true
  end
end
