# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # # SQL queries for creating counts of indicators per created_date
      module SqlQueries
        include Reports::Moh::MigrationHelpers::HaematologyIndicatorCalculations
        include Reports::Moh::MigrationHelpers::SerologyIndicatorCalculations
        include Reports::Moh::MigrationHelpers::ParasitologyIndicatorCalculations
        include Reports::Moh::MigrationHelpers::MicrobiologyIndicatorCalculations
        include Reports::Moh::MigrationHelpers::BloodBankIndicatorCalculations
        include Reports::Moh::MigrationHelpers::BiochemistryIndicatorCalculations

        def generate_query(report_indicator, time_filter, department)
          parameterized_name = report_indicator.parameterize.underscore
          if [
            'Patients with Hb ≤ 6.0g/dl who were transfused', 'Patients with Hb > 6.0 g/dl who were transfused',
            'X-matches done on patients with Hb ≤ 6.0g/dl', 'X-matches done on patients with Hb > 6.0 g/dl'
          ].include?(report_indicator)
            result = '> 6'
            if ['Patients with Hb ≤ 6.0g/dl who were transfused', 'X-matches done on patients with Hb ≤ 6.0g/dl'].include?(report_indicator)
              result = '<= 6'
            end
            query = "SELECT
                  DATE(t2.created_date) AS created_date, '#{report_indicator}' AS indicator,
                    COUNT(DISTINCT t2.id) AS total, '#{department}' AS department, NOW() AS updated_at
              FROM
                tests t2
              INNER JOIN test_types tt2 ON
                tt2.id = t2.test_type_id
              INNER JOIN test_results tr2 ON
                tr2.test_id = t2.id
              INNER JOIN test_indicators ti2 ON
                ti2.test_type_id = tt2.id
              INNER JOIN orders o2 ON
                o2.id = t2.order_id
              INNER JOIN encounters e2 ON
                e2.id = o2.encounter_id
              WHERE
                e2.client_id IN
              (
                SELECT
                  DISTINCT e.client_id
                FROM
                  tests t
                INNER JOIN orders o ON
                  o.id = t.order_id
                INNER JOIN test_types tt ON
                  tt.id = t.test_type_id
                INNER JOIN test_results tr ON
                  tr.test_id = t.id
                INNER JOIN test_indicators ti ON
                  ti.test_type_id = tt.id
                INNER JOIN encounters e ON
                  e.id = o.encounter_id
                WHERE
                  YEAR(t.created_date) = '#{time_filter}'
                  AND tr.value IS NOT NULL
                  AND ExtractNumberFromString(tr.value) #{result} AND tr.value  <> ''
                  AND tt.name IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin')
                    AND ti.name IN ('Hemoglobin', 'Haemoglobin', 'HGB', 'Hb'))
                AND tt2.name = 'Cross-match'
                AND YEAR(t2.created_date) = '#{time_filter}'
                AND ti2.name = 'Pack ABO Group'
                AND
                tr2.value IS NOT NULL
                AND tr2.value <> ''
                GROUP BY DATE(t2.created_date)"
          else
            query = "SELECT created_date AS created_date, '#{report_indicator}' AS indicator,
                  #{send("calculate_#{parameterized_name}")} AS total, '#{department}' AS department, NOW() AS updated_at
                  FROM report_raw_data"
            query << if valid_date?(time_filter)
                      " WHERE created_date = '#{time_filter}'
                        GROUP BY created_date "
                    else
                      " WHERE YEAR(created_date) = '#{time_filter}'
                        GROUP BY created_date "
                    end
          end
          query
        end

        def get_queries(department:, action:, time_filter:)
          queries = []
          report_indicators = Reports::MohService.report_indicators(department)
          report_years = action == 'update' ? [] : Reports::Moh::ReportUtils.report_years
          report_indicators.each do |report_indicator|
            if !report_years.empty?
              report_years.each do |year|
                queries.push(generate_query(report_indicator, year, department))
              end
            else
              queries.push(generate_query(report_indicator, time_filter, department))
            end
          end
          queries
        end

        def valid_date?(string)
          Date.parse(string)
          true
        rescue ArgumentError
          false
        end
      end
    end
  end
end
