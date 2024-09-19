# frozen_string_literal: true

# Module reports
module Reports
  # module aggregate
  module Aggregate
    # module Rejected
    module Rejected
      class << self
        def generate_report(from: nil, to: nil, department: nil)
          department_condition = department.present? ? "AND test_types.department_id = #{department}" : ''
          query = build_query(from, to, department_condition)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          rejected_tests = ActiveRecord::Base.connection.execute(query)
          results = result_by_ward(rejected_tests, department)
          wards = wards(results)
          { wards:, result: results.values }
        end

        private

        def result_by_ward(rejected_tests, department)
          department = Department.find_by(id: department)
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
              COALESCE(
                MAX(status_reasons.description),
                MAX(sr.description)
              ) AS reason_name,
              test_types.name AS test_type,
              COUNT(DISTINCT t.id) AS test_count,
              fs.name AS ward,
              GROUP_CONCAT(DISTINCT t.id) AS associated_ids
            FROM
              tests t
              JOIN orders o ON t.order_id = o.id
              JOIN encounters e ON e.id = o.encounter_id
              JOIN facility_sections fs ON fs.id = e.facility_section_id
              JOIN test_types ON test_types.id = t.test_type_id
              LEFT JOIN test_statuses ON test_statuses.test_id = t.id
              LEFT JOIN statuses ON statuses.id = t.status_id
              LEFT JOIN status_reasons ON status_reasons.id = test_statuses.status_reason_id
              LEFT JOIN order_statuses ON order_statuses.order_id = o.id
              LEFT JOIN statuses as s ON s.id = o.status_id
              LEFT JOIN status_reasons sr ON sr.id = order_statuses.status_reason_id
            WHERE
              (statuses.name = 'test-rejected' OR s.name = 'specimen-rejected')
              #{department_condition}
              AND (DATE(o.created_date) BETWEEN '#{from}' AND '#{to}')
            GROUP BY test_types.name, fs.name;
          SQL
        end
      end
    end
  end
end
