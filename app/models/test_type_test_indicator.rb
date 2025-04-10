# frozen_string_literal: true

# test type indicator table
class TestTypeTestIndicator < VoidableRecord
  self.table_name = 'test_type_indicator_mappings'
  belongs_to :test_type, optional: true, foreign_key: 'test_types_id'
  belongs_to :test_indicator, optional: true, foreign_key: 'test_indicators_id'
end
