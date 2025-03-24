# frozen_string_literal: true

class TestIndicator < RetirableRecord
  belongs_to :test_type, optional: true
  has_many :test_indicator_ranges

  # enum test_indicator_type: [:auto_complete, :free_text, :numeric, :alpha_numeric, :rich_text]
  enum test_indicator_type: {
    auto_complete: 0,
    free_text: 1,
    numeric: 2,
    alpha_numeric: 3,
    rich_text: 4
  }

  def test_indicator_type=(value)
    normalized_value = {
      'AutoComplete' => :auto_complete,
      'Free Text' => :free_text,
      'Numeric' => :numeric,
      'AlphaNumeric' => :alpha_numeric,
      'Rich Text' => :rich_text
    }[value] || value
    super(normalized_value)
  end
end
