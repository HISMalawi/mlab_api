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

    def display_name(full_name, preferred_name)
      if full_name_display?
        full_name
      elsif preferred_name.present?
        preferred_name
      else
        full_name
      end
    end

    def column_display_name(full_name, preferred_name)
      if full_name_display?
        full_name
      else
        "COALESCE(#{preferred_name}, #{full_name})"
      end
    end
  end
end
