# frozen_string_literal: true

test_indicators = TestIndicator.all.select(:id, :test_type_id)
puts 'Migrating test indicators to a many to many relationship with test types ...'
test_indicators.each do |indicator|
  TestTypeTestIndicator.find_or_create_by!(test_types_id: indicator.test_type_id, test_indicators_id: indicator.id)
end
puts 'Migrating done'
