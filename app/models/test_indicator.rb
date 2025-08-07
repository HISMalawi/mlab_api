# frozen_string_literal: true

class TestIndicator < RetirableRecord
  belongs_to :test_type, optional: true
  has_many :test_indicator_ranges
  has_many :test_type_test_indicators, dependent: :destroy, foreign_key: 'test_indicators_id'
  
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

  def test_indicator_type_info
    type_id = read_attribute_before_type_cast(:test_indicator_type)
    type_name = test_indicator_type&.to_s&.gsub('_', ' ')&.titleize || 'Unknown'

    { id: type_id, name: type_name }
  end

  def as_json(options = {})
    super(options).merge({ test_indicator_type: test_indicator_type_info, indicator_ranges: test_indicator_ranges })
  end
end
