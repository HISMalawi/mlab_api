module Reports
  module Aggregate
    module Culture
      class OrganismsInWardCount
        def generate_report(month: nil, year: nil, department: nil)
          data = []
          encounter_types = EncounterType.all
          tests = Test.includes(
            order: { encounter: :facility_section },
            test_type: { test_indicators: :test_indicator_ranges },
            test_status: :status
          ).where(
            test_types: { department_id: department, name: 'Culture & Sensitivity' }
          ).where("MONTH((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", month)
          .where("YEAR((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = 'completed'))) = ?", year)

          encounter_types.each do |encounter_type|
            encountered_wards = Set.new
            encounter_type.facility_sections.each do |facility_section|
              organisms = []
              tests.each do |test|
                if test.requesting_ward == facility_section.name
                  organisms = count_organisms(test.suscept_test_result)
                  break
                end
              end
              unless encountered_wards.include?(facility_section.name)
                data << { encounter: encounter_type.name, ward: facility_section, organisms: organisms }
                encountered_wards.add(facility_section.name)
              end
            end
          end
          data
        end

        private

        def count_organisms(suscept_test_result)
          organisms_count = Hash.new()

          suscept_test_result.each do |result|
            organism_name = result[:name]
            organisms_count[organism_name] ||= 0
            organisms_count[organism_name] += 1
          end

          organisms_count
        end


      end
    end
  end
end
