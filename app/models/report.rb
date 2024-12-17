# frozen_string_literal: true

#  report model
class Report < VoidableRecord
  validates :name, presence: true
  default_scope { where('updated_date >= ?', 20.hours.ago) }
end
