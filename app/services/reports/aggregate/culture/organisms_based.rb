module Reports
  module Aggregate
    module Culture
      class OrganismsBased
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

            if count > 0
              organisms = tests.each_with_object([]) do |test, result|
                has_growth = false
                test.suscept_test_result.each do |suscept_test|
                  if suscept_test[:organism_id] && suscept_test[:name] && suscept_test[:drugs]
                    has_zone = suscept_test[:drugs].present? { |drug| !drug[:zone].nil? }
                    if has_zone
                      has_growth = true
                      existing_organism = result.find { |organism| organism[:name] == suscept_test[:name] }
                      if existing_organism
                        existing_organism[:count] += 1
                      else
                        result << { name: suscept_test[:name], count: 1 }
                      end

                    end
                  end
                end
                result.clear unless has_growth
              end.uniq { |organism| organism[:name] }

              if indicator == 'Growth' && !organisms.empty?
                data[indicator] = { count: count, organisms: organisms }
              else
                data[indicator] = { count: count}
              end

            end
          end

          data
        end
      end
    end
  end
end
