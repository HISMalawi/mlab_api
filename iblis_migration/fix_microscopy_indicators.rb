# frozen_string_literal: true

indicator = {
  name: 'Microscopy',
  nlims_code: 'NLIMS_TI_0820_MWI',
  unit: '/hpf',
  incorrect_supported_Test_types: %w[NLIMS_TT_0012_MWI NLIMS_TT_0017_MWI NLIMS_TT_0236_MWI]
}

puts "Processing indicator: #{indicator[:name]} with nlims_code: #{indicator[:nlims_code]}"
test_types = TestType.where(nlims_code: indicator[:incorrect_supported_Test_types])

puts "Found #{test_types.count} test types with nlims codes: #{indicator[:incorrect_supported_Test_types].join(', ')}"
puts "Test types found: #{test_types.pluck(:name).join(', ')}"
puts "Updating TestTypeTestIndicator associations for indicator with nlims_code: #{indicator[:nlims_code]}"
TestTypeTestIndicator.where(
  test_types_id: test_types.pluck(:id),
  test_indicators_id: TestIndicator.find_by(nlims_code: indicator[:nlims_code])&.id
)&.update_all(test_indicators_id: TestIndicator.find_by(nlims_code: 'NLIMS_TI_0605_MWI')&.id)
puts "Updating MeasureRange associations for indicator with nlims_code: #{indicator[:nlims_code]}"
TestIndicatorRange.where(
  test_indicator_id: TestIndicator.find_by(nlims_code: indicator[:nlims_code])&.id,
  test_type_id: test_types.pluck(:id)
)&.update_all(test_indicator_id: TestIndicator.find_by(nlims_code: 'NLIMS_TI_0605_MWI')&.id)
puts 'Done'
