# frozen_string_literal: true

# Module global service
module GlobalService
  class << self
    def current_location
      Global.first
    end

    def full_name_display?
      AppSetting.find_by(name: 'test_name_display')&.value == 'full_name'
    end
  end
end
