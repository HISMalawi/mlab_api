# frozen_string_literal: true

# Load lab locations if they do not exist

lab_locations = [{
  name: 'Ward',
  description: 'Ward'
}]

lab_locations.each do |location|
  LabLocation.find_or_create_by!(name: location[:name]) do |lab_location|
    lab_location.description = location[:description]
  end
end
puts 'Lab locations loaded successfully.'
