# frozen_string_literal: true

test_types = TestType.where(name: ['Cross-match', 'ABO Blood Grouping'])

test_indicators = TestTypeTestIndicator.joins(:test_indicator)
                                       .where(
                                         '(
                                          test_indicators.name LIKE ? OR
                                          test_indicators.name LIKE ? OR
                                          test_indicators.name LIKE ?
                                        )',
                                         '%Lab Tech%', '%Collected By%', '%Time Collected%'
                                       )
                                       .where.not(test_type_indicator_mappings: { test_types_id: test_types.pluck(:id) })
blood_test_indicators = TestTypeTestIndicator.joins(:test_indicator)
                                             .where(
                                               '(
                                            test_indicators.name LIKE ? OR
                                            test_indicators.name LIKE ?
                                          )', '%Collected By%', '%Time Collected%'
                                             )
                                             .where(test_type_indicator_mappings: { test_types_id: test_types.pluck(:id) })
test_indicators.each do |test_indicator|
  test_indicator.void('No longer used')
end

blood_test_indicators.each do |test_indicator|
  test_indicator.void('No longer used')
end

lab_tech_indicators = TestIndicator.where("name like '%Lab Tech%'")
lab_tech_indicators.each do |test_indicator|
  test_indicator.update(preferred_name: test_indicator.name,
                        short_name: test_indicator.name,
                        scientific_name: test_indicator.name)
  TestTypeTestIndicator.where(test_indicators_id: test_indicator.id).each do |test_type_test_indicator|
    test_type_test_indicator.update(test_indicator_type: 'free_text', unit: '')
  end
end
