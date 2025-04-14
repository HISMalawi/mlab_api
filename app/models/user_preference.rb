# frozen_string_literal: true

# UserPreference model
class UserPreference < VoidableRecord
  belongs_to :users, class_name: 'User', optional: true, foreign_key: 'creator'
end
