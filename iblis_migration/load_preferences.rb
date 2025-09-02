# frozen_string_literal: true

preferences = [
  {
    name: 'elasticsearch_enable_high_accuracy',
    value: {
      options: %w[true false],
      default: 'true',
      description: 'Enable high accuracy for Elasticsearch'
    }
  },
  {
    name: 'grid_or_list_enter_result_view',
    value: {
      options: %w[grid list],
      default: 'grid',
      description: 'Enter result view in grid or list format'
    }
  },
  {
    name: 'test_name_display',
    value: {
      options: %w[full_name preferred_name],
      default: 'full_name',
      description: 'Display format of names (full name or preferred name)'
    }
  }
]
preferences.each do |preference|
  # Check if the preference already exists
  puts "Looding preference: #{preference[:name]}"
  existing_preference = Preference.find_by(name: preference[:name])

  # If it doesn't exist, create it
  next if existing_preference.present?

  Preference.create!(
    name: preference[:name],
    value: preference[:value].to_json,
    creator: User.current&.id || User.first&.id
  )
end
