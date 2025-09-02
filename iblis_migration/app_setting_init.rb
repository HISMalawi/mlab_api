# frozen_string_literal: true

# Initialize app settings
preferences = [
  {
    name: 'test_name_display',
    value: 'full_name'
  }
]
preferences.each do |preference|
  app_setting = AppSetting.find_by(name: preference[:name])
  AppSetting.create!(name: preference[:name], value: preference[:value]) unless app_setting.present?
end
