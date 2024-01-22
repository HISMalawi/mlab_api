module Reports
  module Aggregate
    class Infection
      def generate_report(from: Date.today.to_s, to: Date.today.to_s, department: nil)
        get_data(from, to, department)
      end

      def get_summary(department: nil, from: nil, to: nil)
        department = department.present? ? " AND t.department_id = #{department}" : ''
        query = <<-SQL
          SELECT t.name, COUNT(*) AS test_count
          FROM tests AS ts
          JOIN test_types AS t ON ts.test_type_id = t.id
          WHERE (ts.created_date BETWEEN '#{from}' AND '#{to}')
          #{department}
          GROUP BY t.name
        SQL
        ActiveRecord::Base.connection.execute(query)
      end

      def get_data(from, to, department)
        where_condition = " DATE(t.created_date) BETWEEN '#{Date.parse(from).beginning_of_day}' and '#{Date.parse(to).end_of_day}'"
        where_condition = where_condition << " AND tt.department_id = '#{department}'" unless department.nil?

        Report.find_by_sql(
          "SELECT DISTINCT
          t.id,
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
              WHEN tr.value = '0' THEN NULL
              WHEN tr.value = '' THEN NULL
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
          p.sex AS gender
      FROM
          tests t
              INNER JOIN
          test_types tt ON tt.id = t.test_type_id
              INNER JOIN
          test_statuses ts ON ts.test_id = t.id
              INNER JOIN
          test_indicators ti ON ti.test_type_id = t.test_type_id
              INNER JOIN
          orders o ON o.id = t.order_id
              INNER JOIN
          encounters e ON e.id = o.encounter_id
              INNER JOIN
          clients c ON c.id = e.client_id
              INNER JOIN
          people p ON p.id = c.person_id
              LEFT JOIN
          test_results tr ON tr.test_id = t.id
              AND ti.id = tr.test_indicator_id
              LEFT JOIN
          test_indicator_ranges tir ON tir.test_indicator_id = ti.id
              AND tir.retired = 0
      WHERE
          ts.status_id IN (4 , 5)
              AND (tir.max_age IS NULL OR tir.max_age > 0) AND
              #{where_condition}"
        )
      end

      def calculate_count(records)
        data = {}
        records.each do |record|
          data[record['test']] = {
            "#{record['measure']}" => {
              "#{record['result']}": increments_age_range(i_data, record['age_group'], record['result'], record['gender'])
            }
          }
        end
        data
      end

      private

      def calculate_age(date_of_birth, created_date)
        age = 0
        unless date_of_birth.nil?
          birth_date = Date.parse(date_of_birth)
          now = created_date
          age = now.year - birth_date.year
          age -= 1 if now.month < birth_date.month || (now.month == birth_date.month && now.day < birth_date.day)
        end
        age
      end

      def increment_age_range(indicator_data, result, sex, age)
        sex_range = indicator_data[sex]
        if age.between?(0, 5)
          sex_range['0-5'] += result.nil? ? 1 : 0
        elsif age.between?(6, 14)
          sex_range['5-14'] += result.nil? ? 1 : 0
        elsif age.between?(15, 120)
          sex_range['14-120'] += result.nil? ? 1 : 0
        end
      end

      def increments_age_range(i_data, age_group, result, gender)
        sex_range = i_data[gender]
        if age_group == 'L_E_5'
          sex_range['0-5'] += result.nil? ? 0 : 1
        elsif age_group == 'G_5_L_E_14'
          sex_range['5-14'] += result.nil? ? 0 : 1
        elsif age_group == 'G_14'
          sex_range['14-120'] += result.nil? ? 0 : 1
        end
      end
    end
  end
end
