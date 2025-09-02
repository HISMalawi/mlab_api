# frozen_string_literal: true

# test type indicator table
class TestTypeTestIndicator < VoidableRecord
  self.table_name = 'test_type_indicator_mappings'
  belongs_to :test_type, optional: true, foreign_key: 'test_types_id'
  belongs_to :test_indicator, optional: true, foreign_key: 'test_indicators_id'

  enum test_indicator_type: %i[auto_complete free_text numeric alpha_numeric rich_text]

  def test_indicator_type=(value)
    normalized_value = {
      'AutoComplete' => :auto_complete,
      'Free Text' => :free_text,
      'Numeric' => :numeric,
      'Numeric Range' => :numeric,
      'AlphaNumeric' => :alpha_numeric,
      'Alphanumeric Values' => :alpha_numeric,
      'Rich Text' => :rich_text
    }[value] || value
    super(normalized_value)
  end
end
