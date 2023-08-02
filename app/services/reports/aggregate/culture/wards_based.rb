module Reports
  module Aggregate
    module Culture
      class WardsBased
        def generate_report(month: nil, year: nil)
          data = []
          department = Department.find_by(name: 'Microbiology').id
          tests = Test.joins(:test_type)
            .where(test_types: { department_id: department, name: 'Culture & Sensitivity' })
            .where("MONTH((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", month)
            .where("YEAR((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", year)
          test_type = TestType.find_by(name: 'Culture & Sensitivity')
          test_catalog_service = TestCatalog::TestTypes::ShowService.show_test_type(test_type)
          indicator_ranges = test_catalog_service[:indicators][0][:indicator_ranges].map { |range| range["value"] }
          encounter_types = EncounterType.all
          encounter_types.each do |encounter|
            encounter.facility_sections.each do |section|
              count = 0
              indicator_ranges.each do |indicator|
                count += tests.count do |test|
                  if test.request_origin == encounter.name && section["name"] == test.requesting_ward
                    test.indicators.any? do |i|
                      !i[:result].nil? && i[:result]['value'] == indicator
                    end
                  end
                end
              end
              unless count.zero?
                data << { ward: section["name"], encounter: encounter.name, count: count }
              end
            end
          end
          data
        end
      end
    end
  end
end
