# frozen_string_literal: true

# Test Panel
class TestPanel < RetirableRecord
  validates :name, uniqueness: true, presence: true

  has_many :test_type_panel_mappings, dependent: :destroy
  has_many :test_types, through: :test_type_panel_mappings
end
