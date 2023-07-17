module Reports
  module Aggregate
    module Culture
      class GeneralCount
        def generate_report(month: nil, year: nil, department: nil)
          data = {}
          tests = Test.includes(test_type: :test_indicators)
            .where(test_types: { department_id: department, name: 'Culture & Sensitivity' })
            .where("MONTH((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", month)
            .where("YEAR((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", year)
          test_type = TestType.includes(:test_indicators).find_by(name: 'Culture & Sensitivity')
          test_catalog_service = TestCatalog::TestTypes::ShowService.show_test_type(test_type)
          indicator_ranges = test_catalog_service[:indicators][0][:indicator_ranges].map { |range| range["value"] }
          indicator_ranges.each do |indicator|
            count = tests.count do |test|
              test.indicators.any? do |i|
                !i[:result].nil? && i[:result]['value'] == indicator
              end
            end
            data[indicator] = count
          end
          data
        end
      end
    end
  end
end
