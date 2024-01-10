# frozen_string_literal: true

#  report model
class Report < VoidableRecord
  validates :name, presence: true
end
