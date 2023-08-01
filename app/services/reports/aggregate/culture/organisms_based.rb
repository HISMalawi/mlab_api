module Reports
  module Aggregate
    module Culture
      class OrganismsBased
        def generate_report(month: nil, year: nil)
          department_id = Department.find_by(name: 'Microbiology')&.id
          tests = Test.joins(test_type: [:test_indicators])
          .where('test_types.department_id = ?', department_id)
          .where('test_types.name = ?', 'Culture & Sensitivity')
          .where('MONTH((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = ?))) = ?', 'completed', month)
          .where('YEAR((SELECT MAX(st.created_date) FROM test_statuses st WHERE st.test_id = tests.id AND st.status_id = (SELECT id FROM statuses WHERE name = ?))) = ?', 'completed', year)
          .distinct
          data = []
          tests.each do |test|
            test.suscept_test_result.each do |suscept_test|
              organism_name = suscept_test[:name]
              existing_data = data.find { |d| d[:organism] == organism_name }
              if existing_data
                existing_data[:count] += 1
              else
                data << { organism: organism_name, count: 1 }
              end
            end
          end
          data
        end
      end
    end
  end
end
