# frozen_string_literal: true

# Lab location model
class LabLocation < VoidableRecord
  validates :name, uniqueness: true, presence: true
end
