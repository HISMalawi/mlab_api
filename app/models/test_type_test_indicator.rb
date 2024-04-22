# frozen_string_literal: true

# test type indicator table
class TestTypeTestIndicator < VoidableRecord
  self.table_name = 'test_type_indicator_mappings'
  belongs_to :test_type
  belongs_to :test_indicator
end
