# frozen_string_literal: true

# NameMapping model
class NameMapping < VoidableRecord
  self.table_name = 'name_mapping'
  validates :actual_name, presence: true
  validates :manual_name, presence: true, uniqueness: true
end
