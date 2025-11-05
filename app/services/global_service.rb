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

    def fetch_ids(model, actual_name, nlims_code = [])
      manual_names = NameMapping.where(actual_name:).map(&:manual_name)
      manual_names = Array(actual_name) + manual_names
      ids = model.where('TRIM(name) IN (?)', manual_names.map(&:strip)).map(&:id)
      if nlims_code.present?
        ids_by_code = model.where(nlims_code:).map(&:id)
        ids.concat(ids_by_code)
      end
      ids.uniq!
      return "('unknow_or_empty')" if ids.empty?

      "(#{ids.join(', ')})"
    end
  end
end
