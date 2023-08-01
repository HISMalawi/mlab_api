module Reports
  module Aggregate
    module Culture
      class OrganismsBased
        def generate_report(month: nil, year: nil)
          department_id = Department.find_by(name: 'Microbiology')&.id
          query = <<-SQL
          SELECT *
          FROM tests
          JOIN test_types ON tests.test_type_id = test_types.id
          LEFT JOIN test_indicators ON test_types.id = test_indicators.test_type_id
          LEFT JOIN test_results ON tests.id = test_results.test_id AND test_indicators.id = test_results.test_indicator_id
          WHERE test_types.department_id = #{department_id}
            AND test_types.name = 'Culture & Sensitivity'
            AND MONTH((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = #{month}
            AND YEAR((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = #{year};

          SQL
          tests = Test.find_by_sql(query)

          test_type = TestType.includes(:test_indicators).find_by(name: 'Culture & Sensitivity')
          test_catalog_service = TestCatalog::TestTypes::ShowService.show_test_type(test_type)
          indicator_ranges = test_catalog_service[:indicators][0][:indicator_ranges].map { |range| range['value'] }

          data = {}
          tests.each do |test|
            test_indicators = test.indicators
            next if test_indicators.none? { |i| !i[:result].nil? && indicator_ranges.include?(i[:result]['value']) }

            count = test_indicators.count do |i|
              !i[:result].nil? && indicator_ranges.include?(i[:result]['value'])
            end

            next if count.zero?

            organisms = test.suscept_test_result.each_with_object([]) do |suscept_test, result|
              next unless suscept_test[:organism_id] && suscept_test[:name] && suscept_test[:drugs]

              has_zone = suscept_test[:drugs].any? { |drug| !drug[:zone].nil? }
              next unless has_zone

              existing_organism = result.find { |organism| organism[:name] == suscept_test[:name] }
              if existing_organism
                existing_organism[:count] += 1
              else
                result << { name: suscept_test[:name], count: 1 }
              end
            end.uniq { |organism| organism[:name] }

            if indicator_ranges.include?('Growth') && !organisms.empty?
              data['Growth'] = { count: count, organisms: organisms }
            else
              data[indicator_ranges.first] = { count: count }
            end
          end

          tests
        end
      end
    end
  end
end
