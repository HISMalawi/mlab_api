module Reports
  module Aggregate
    class Rejected
      def generate_report(from: nil, to: nil, department: nil)
        query = <<-SQL
        SELECT
          status_reasons.description AS reason_name,
          test_types.name AS test_type_name,
          COUNT(*) AS test_count,
          fs.name AS ward
        FROM
          tests
        JOIN orders o ON tests.order_id = o.id
        JOIN encounters e ON e.id = o.encounter_id
        JOIN facility_sections fs ON fs.id = e.facility_section_id
        JOIN test_statuses ON test_statuses.test_id = tests.id
        JOIN
          statuses ON statuses.id = test_statuses.status_id
        JOIN
          status_reasons ON status_reasons.id = test_statuses.status_reason_id
        JOIN
          test_types ON test_types.id = tests.test_type_id
        WHERE
          statuses.name = 'test-rejected'
          AND test_types.department_id = #{department.present? ? department.to_i : ''}
          AND tests.created_date >= '#{from.to_date}'
          AND tests.created_date <= '#{to.to_date}'
        GROUP BY
          status_reasons.description, test_types.name, fs.name;
        SQL
        rejected_tests = ActiveRecord::Base.connection.execute(query)
        wards = []
        result = []
        rejected_tests.each do |reason_name, test_type_name, test_count, ward|
          existing_reason = result.find { |reason| reason[:name] == reason_name }
          wards << ward
          if existing_reason
            existing_reason[:test_types] << { name: test_type_name, count: test_count, ward:}
          else
            new_reason = {
              name: reason_name,
              test_types: [{ name: test_type_name, ward: , count: test_count }]
            }
            result << new_reason
          end
        end
        data = { 'wards' => wards.uniq, 'result' => result }
        data
      end
    end
  end
end
