# frozen_string_literal: true

# AppSetting model
class AppSetting < VoidableRecord
  validates_uniqueness_of :name
end
