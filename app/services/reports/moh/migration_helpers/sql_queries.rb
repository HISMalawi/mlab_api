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
