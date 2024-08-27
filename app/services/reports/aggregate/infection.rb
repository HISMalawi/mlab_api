module Reports
  module Aggregate
    class Infection
      def generate_report(from: Date.today.to_s, to: Date.today.to_s, department: nil)
        department = Department.find_by_name(department)&.id
        process_data(serliarize_data(get_data(from, to, department)))
      end

      def get_summary(from: Date.today.to_s, to: Date.today.to_s, department: nil)
        department = Department.find_by_name(department)
        department_condition = department.present? ? " AND tt.department_id = #{department&.id}" : ''

        query = <<-SQL
          SELECT tt.name, COUNT(DISTINCT t.id) AS count, GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests AS t
          JOIN test_types AS tt ON t.test_type_id = tt.id
          INNER JOIN
          test_statuses ts ON ts.test_id = t.id
          WHERE ts.status_id IN (4 , 5)
          AND (t.created_date BETWEEN '#{from.to_date.beginning_of_day}' AND '#{to.to_date.end_of_day}')
          #{department_condition}
          GROUP BY tt.name
        SQL
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        serliarize_summary(Report.find_by_sql(query), department&.name)
      end

      private

      def get_data(from, to, department)
        condition = " DATE(t.created_date) BETWEEN '#{from.to_date.beginning_of_day}' and '#{to.to_date.end_of_day}'"
        condition <<= " AND tt.department_id = '#{department}'" unless department.nil?
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql(
          "SELECT DISTINCT
          tt.name AS test,
          ti.name AS measure,
          CASE
              WHEN
                  TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
              THEN
                  'L_E_5'
              WHEN
                  TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) > 5
                      AND TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 14
              THEN
                  'G_5_L_E_14'
              ELSE 'G_14'
          END AS age_group,
          CASE
              WHEN
                  ti.test_indicator_type = 2
                      AND tr.value BETWEEN tir.lower_range AND tir.upper_range
                      AND (CAST(Replace(tr.value, '^', '') AS DECIMAL(10,2)) != 0)
              THEN
                  'Normal'
              WHEN
                  ti.test_indicator_type = 2
                      AND tr.value < tir.lower_range
                      AND (CAST(Replace(tr.value, '^', '') AS DECIMAL(10,2)) != 0)
              THEN
                  'Low'
              WHEN
                  ti.test_indicator_type = 2
                      AND tr.value > tir.upper_range
                      AND (CAST(Replace(tr.value, '^', '') AS DECIMAL(10,2)) != 0)
              THEN
                  'High'
              ELSE tr.value
          END AS result,
          p.sex AS gender,
          COUNT(DISTINCT t.id) AS total,
          GROUP_CONCAT(DISTINCT t.id) AS associated_ids
      FROM
          tests t
              INNER JOIN
          test_types tt ON tt.id = t.test_type_id
              INNER JOIN
          test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
              INNER JOIN
          test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
          orders o ON o.id = t.order_id
              INNER JOIN
          encounters e ON e.id = o.encounter_id
              INNER JOIN
          clients c ON c.id = e.client_id
              INNER JOIN
          people p ON p.id = c.person_id
              LEFT JOIN
          test_results tr ON tr.test_id = t.id AND tr.voided = 0
              AND ti.id = tr.test_indicator_id
              LEFT JOIN
          test_indicator_ranges tir ON tir.test_indicator_id = ti.id
              AND tir.retired = 0
      WHERE
          t.status_id IN (4 , 5)
              AND (tir.max_age IS NULL OR tir.max_age > 0) AND ti.name != 'Pack No.'
              AND ti.name != 'Expiry Date' AND ti.name != 'Volume'
              AND tr.value IS NOT NULL AND tr.value NOT IN ('', '0') AND
              #{condition} GROUP BY test, measure, age_group, result, gender"
        )
      end

      def serliarize_summary(records, department)
        data = []
        records.each do |record|
          data.push(
            {
              name: record['name'],
              total: record['count'],
              associated_ids: UtilsService.insert_drilldown(record, department)
            }
          )
        end
        data
      end

      def serliarize_data(records)
        data = []
        records.each do |record|
          data.push(
            {
              total: record['total'],
              test_type: record['test'],
              indicator: record['measure'],
              age_group: record['age_group'],
              result: record['result'],
              gender: record['gender'],
              associated_ids: record['associated_ids']
            }
          )
        end
        data
      end

      def process_data(data)
        test_hash = {}
        data.each do |test_|
          test_type = test_[:test_type].to_s
          total = test_[:total].to_i
          indicator = test_[:indicator].to_s
          age_group = test_[:age_group].to_s
          result = test_[:result].to_s
          gender = test_[:gender].to_s
          associated_ids = UtilsService.insert_drilldown(test_, nil)

          test_hash[test_type] ||= {}
          test_hash[test_type][indicator] ||= []
          result_hash = test_hash[test_type][indicator].find { |item| item.key?(result.to_sym) }
          result_hash ||= { result => [] }
          test_hash[test_type][indicator] << result_hash unless test_hash[test_type][indicator].include?(result_hash)
          age_group_hash = result_hash[result].find { |item| item.key?(age_group.to_sym) }
          age_group_hash ||= { age_group => {} }
          result_hash[result] << age_group_hash unless result_hash[result].include?(age_group_hash)

          age_group_hash[age_group][gender] ||= { count: 0, associated_ids: '' }
          age_group_hash[age_group][gender][:count] += total.to_i
          age_group_hash[age_group][gender][:associated_ids] = associated_ids
        end

        test_hash.map do |test_type, indicator|
          {
            test_type:,
            measures: indicator.map do |measure, result|
              result = result.group_by { |h| h.keys.first }.map do |key, hashes|
                merged_values = hashes.flat_map { |h| h[key] }
                { key => merged_values }
              end
              {
                name: measure,
                results: result.map do |value, _|
                  x = value.map do |key, hashes|
                    { key => hashes.inject({}) do |acc, sub_hash|
                      acc.merge(sub_hash) { |_, a, b| a.is_a?(Hash) && b.is_a?(Hash) ? a.merge(b) : [a, b] }
                    end }
                  end
                  x.map do |result_|
                    {
                      result_.keys.first => {
                        'F' => result_.values.first.map do |age_group, genders|
                          [age_group,
                           { count: genders['F']&.dig(:count) || 0,
                             associated_ids: genders['F']&.dig(:associated_ids) || '' }]
                        end.to_h,
                        'M' => result_.values.first.map do |age_group, genders|
                          [age_group,
                           { count: genders['M']&.dig(:count) || 0,
                             associated_ids: genders['M']&.dig(:associated_ids) || '' }]
                        end.to_h
                      }
                    }
                  end
                end
              }
            end
          }
        end
      end
    end
  end
end
