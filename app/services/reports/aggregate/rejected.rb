# frozen_string_literal: true

# Module reports
module Reports
  # module aggregate
  module Aggregate
    # module Rejected
    module Rejected
      class << self
        def generate_report(from: nil, to: nil, department: nil)
          department_condition = department.present? ? "AND test_types.department_id = #{department.to_i}" : ''
          query = build_query(from, to, department_condition)
          rejected_tests = ActiveRecord::Base.connection.execute(query)
          results = result_by_ward(rejected_tests)
          wards = wards(results)
          { wards:, result: results.values }
        end

        private

        def result_by_ward(rejected_tests)
          rejected_tests.each_with_object({}) do |(reason_name, test_type_name, test_count, ward), result|
            reason = result[reason_name] ||= { name: reason_name, test_types: [] }
            reason[:test_types] << { name: test_type_name, count: test_count, ward: }
          end
        end

        def wards(results)
          results.values.flat_map { |reason| reason[:test_types] }.map { |test_type| test_type[:ward] }.uniq
        end

        def build_query(from, to, department_condition)
          <<~SQL
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
              JOIN statuses ON statuses.id = test_statuses.status_id
              JOIN status_reasons ON status_reasons.id = test_statuses.status_reason_id
              JOIN test_types ON test_types.id = tests.test_type_id
            WHERE
              statuses.name LIKE '%rejected%'
              #{department_condition}
              AND (DATE(o.created_date) BETWEEN '#{from}' AND '#{to}')
            GROUP BY
              status_reasons.description, test_types.name, fs.name;
          SQL
        end
      end
    end
  end
end
