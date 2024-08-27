# frozen_string_literal: true

# Module reports
module Reports
  # module aggregate
  module Aggregate
    # module Rejected
    module Rejected
      class << self
        def generate_report(from: nil, to: nil, department: nil)
          department = Department.find_by(name: department)
          department_condition = department.present? ? "AND test_types.department_id = #{department&.id}" : ''
          query = build_query(from, to, department_condition)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          rejected_tests = ActiveRecord::Base.connection.execute(query)
          results = result_by_ward(rejected_tests, department)
          wards = wards(results)
          { wards:, result: results.values }
        end

        private

        def result_by_ward(rejected_tests, department)
          rejected_tests.each_with_object({}) do |(reason_name, test_type, test_count, ward, associated_ids), result|
            reason = result[reason_name] ||= { name: reason_name, test_types: [] }
            associated_ids = UtilsService.insert_drilldown({ associated_ids: }, department&.name)
            reason[:test_types] << { name: test_type, count: test_count, ward:, associated_ids: }
          end
        end

        def wards(results)
          results.values.flat_map { |reason| reason[:test_types] }.map { |test_type| test_type[:ward] }.uniq
        end

        def build_query(from, to, department_condition)
          <<~SQL
            SELECT
              status_reasons.description AS reason_name,
              test_types.name AS test_type,
              COUNT(DISTINCT t.id) AS test_count,
              fs.name AS ward,
              GROUP_CONCAT(DISTINCT t.id) AS associated_ids
            FROM
              tests t
              JOIN orders o ON t.order_id = o.id
              JOIN encounters e ON e.id = o.encounter_id
              JOIN facility_sections fs ON fs.id = e.facility_section_id
              JOIN test_statuses ON test_statuses.test_id = t.id
              JOIN statuses ON statuses.id = test_statuses.status_id
              JOIN status_reasons ON status_reasons.id = test_statuses.status_reason_id
              JOIN test_types ON test_types.id = t.test_type_id
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
