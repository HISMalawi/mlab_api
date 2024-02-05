# frozen_string_literal: true

# Reports modules
module Reports
  # Aggregate report module
  module Aggregate
    # Department report class
    class DepartmentReport
      attr_accessor :from, :to, :department, :sql

      def initialize(from, to, department)
        @from = from
        @to = to
        @department = department
        @sql = <<-SQL
            SELECT
                tt.name test_type,
                fs.name ward,
                MONTHNAME(t.created_date) month,
                COUNT(DISTINCT t.id) count
            FROM
                tests t
                    JOIN
                test_types tt ON tt.id = t.test_type_id AND tt.department_id = #{Department.find_by_name(@department)&.id}
                    JOIN
                orders o ON o.id = t.order_id
                    JOIN
                encounters e ON e.id = o.encounter_id
                    JOIN
                facility_sections fs ON fs.id = e.facility_section_id
                    JOIN
                test_statuses ts on ts.test_id = t.id
            WHERE
                  ts.status_id IN (4,5)
                    AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
            GROUP BY test_type , ward , MONTHNAME(t.created_date)
        SQL
      end

      def generalize_depart_report
        data = Report.find_by_sql(@sql)
        blood_bank_products = @department == 'Blood Bank' ? blood_bank_product_report : []
        critical_values = %w[Haematology Biochemistry Paediatric].include?(@department) ? department_critical_values : []
        {
          from:,
          to:,
          department:,
          wards: wards(data),
          data: serialize_generalize_depart_report(data),
          critical_values:,
          blood_bank_products:
        }
      end

      def blood_bank_product_report
        sql_query = <<-SQL
        SELECT
            tr.value blood_product,
            fs.name ward,
            CASE
                WHEN
                    (TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5)
                THEN
                    '0-5'
                WHEN
                    (TIMESTAMPDIFF(YEAR,
                          DATE(p.date_of_birth),
                          DATE(t.created_date)) > 5)
                          AND (TIMESTAMPDIFF(YEAR,
                          DATE(p.date_of_birth),
                          DATE(t.created_date)) <= 15)
                  THEN
                      '6-14'
                  ELSE '15-120'
              END age_range,
              CASE
                  WHEN p.sex = 'M' THEN 'Male'
                  ELSE 'Female'
              END AS gender,
              COUNT(DISTINCT t.id) AS count
          FROM
              tests t
                  JOIN
              test_types tt ON tt.id = t.test_type_id
                  AND tt.department_id = #{Department.find_by_name(@department)&.id}
                  JOIN
              orders o ON o.id = t.order_id
                  JOIN
              encounters e ON e.id = o.encounter_id
                  JOIN
              clients c ON c.id = e.client_id
                  JOIN
              people p ON p.id = c.person_id
                  JOIN
              facility_sections fs ON fs.id = e.facility_section_id
                  JOIN
              test_statuses ts ON ts.test_id = t.id
                  JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  JOIN
              test_results tr ON tr.test_id = t.id
                  AND ti.id = tr.test_indicator_id
          WHERE
              ts.status_id IN (4 , 5)
                  AND tr.value IN ('Whole Blood' , 'Packed Red Cells',
                  'Platelets',
                  'FFPs',
                  'Cryoprecipitate')
                  AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
          GROUP BY blood_product , ward , age_range , gender
        SQL
        data = Report.find_by_sql(sql_query)
        serialize_blood_products(data)
      end

      def department_critical_valuestotal_test_count
        sql_query = <<-SQL
          SELECT 
              ti.name test_indicator_name,
              fs.name ward,
              CASE
                      WHEN ExtractNumberFromString(tr.value) < tir.lower_range THEN 'Low'
                      WHEN ExtractNumberFromString(tr.value) > tir.upper_range THEN 'High'
                      ELSE 'Normal'
                    END AS critical_value_level,
              COUNT(DISTINCT t.id) AS count
          FROM
              tests t
                  JOIN
              test_types tt ON tt.id = t.test_type_id
                  AND tt.department_id = #{Department.find_by_name(@department)&.id}
                  JOIN
              orders o ON o.id = t.order_id
                  JOIN
              encounters e ON e.id = o.encounter_id
                  JOIN
              clients c ON c.id = e.client_id
                  JOIN
              people p ON p.id = c.person_id
                  JOIN
              facility_sections fs ON fs.id = e.facility_section_id
                  JOIN
              test_statuses ts ON ts.test_id = t.id
                  JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id join test_indicator_ranges tir on tir.test_indicator_id = ti.id
                  JOIN
              test_results tr ON tr.test_id = t.id
                  AND ti.id = tr.test_indicator_id
          WHERE
              ts.status_id IN (4 , 5)
                  AND tr.value NOT IN ('', '0') AND tr.value IS NOT NULL
                  AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
          GROUP BY test_indicator_name,ward, critical_value_level;
        SQL
        data = Report.find_by_sql(sql_query)
        serialize_critical_values(data)
      end

      def serialize_generalize_depart_report(data)
        data.group_by { |entry| entry['month'].downcase }.map do |month, month_entries|
          {
            month.to_sym => month_entries.group_by do |entry|
                              entry['test_type'].downcase
                            end
                                         .map do |test_type, test_type_entries|
                              {
                                "test_type": test_type,
                                "ward": test_type_entries.map do |entry|
                                          { entry['ward'] => entry['count'] }
                                        end.reduce({}, :merge)
                              }
                            end
          }
        end
      end

      def serialize_critical_values(data)
        data.group_by { |entry| entry['test_indicator_name'].downcase }.map do |test_indicator_name, test_indicator_name_entries|
          {
            test_indicator_name.to_sym => test_indicator_name_entries.group_by do |entry|
                              entry['critical_value_level'].downcase
                            end
                                         .map do |critical_value, critical_value_entries|
                              {
                                "critical_value_level": critical_value,
                                "ward": critical_value_entries.map do |entry|
                                          { entry['ward'] => entry['count'] }
                                        end.reduce({}, :merge)
                              }
                            end
          }
        end
      end

      def serialize_blood_products(data)
        data.group_by { |entry| entry['blood_product'].downcase }.map do |blood_product, blood_product_entries|
          {
            blood_product.to_sym => blood_product_entries.group_by do |entry|
                              entry['gender'].downcase
                            end
                                         .map do |gender, gender_entries|
                              {
                                "gender": gender,
                                "ward": gender_entries.group_by do |entry|
                                  entry['ward'].downcase
                                end
                                .map do |ward, entries|
                                  {
                                    ward.to_sym => entries.map do |entry|
                                      {entry['age_range'] => entry['count']}
                                    end.reduce({}, :merge)
                                  }
                                end
                              }
                            end
          }
        end
      end

      def wards(data)
        wards_ = data.map do |entry|
          entry['ward']
        end
        wards_.uniq.sort
      end
    end
  end
end
