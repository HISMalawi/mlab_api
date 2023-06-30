module Reports
  module Aggregate
    class Rejected
      def generate_report(from: nil, to: nil, department: nil)
        query = <<-SQL
        SELECT
          status_reasons.description AS reason_name,
          test_types.name AS test_type_name,
          COUNT(*) AS test_count
        FROM
          tests
        JOIN
          test_statuses ON test_statuses.test_id = tests.id
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
          status_reasons.description, test_types.name;
        SQL
        rejected_tests = ActiveRecord::Base.connection.execute(query)
        result = []
        rejected_tests.each do |reason_name, test_type_name, test_count|
          existing_reason = result.find { |reason| reason[:name] == reason_name }

          if existing_reason
            existing_reason[:test_types] << { name: test_type_name, count: test_count }
          else
            new_reason = {
              name: reason_name,
              test_types: [{ name: test_type_name, count: test_count }]
            }
            result << new_reason
          end
        end
        result
      end
    end
  end
end
