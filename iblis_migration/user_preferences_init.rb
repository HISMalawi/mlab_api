# frozen_string_literal: true

preferences = Preference.all

User.all.each do |user|
  preferences.each do |preference|
    next if UserPreference.where(name: preference.name, creator: user.id).exists?

    puts "Looding preference: #{preference.name} for user: #{user.id}"
    UserPreference.create!(
      name: preference.name,
      value: JSON.parse(preference.value)['default'],
      creator: user.id
    )
  end
end
