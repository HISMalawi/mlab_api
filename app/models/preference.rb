# frozen_string_literal: true

# Preference model
class Preference < VoidableRecord
  validates_uniqueness_of :name
  belongs_to :users, class_name: 'User', optional: true, foreign_key: 'creator'
end
