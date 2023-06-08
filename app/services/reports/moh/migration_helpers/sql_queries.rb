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
        

        def generate_query(report_indicator, year, department)
          parameterized_name = report_indicator.parameterize.underscore
          <<-SQL
                SELECT created_date AS created_date, '#{report_indicator}' AS indicator,
                #{send("calculate_#{parameterized_name}")} AS total, '#{department}' AS department, NOW() AS updated_at
                FROM report_raw_data
                WHERE YEAR(created_date) = '#{year}'
                GROUP BY created_date
          SQL
        end

        def haematology_queries
          queries = []
          report_indicators = Reports::Moh::Haematology.new.report_indicator
          report_years = Reports::Moh::ReportUtils::LOAD_PROCEDURE_YEARS_DATA
          report_indicators.each do |report_indicator|
            report_years.each do |year|
              queries.push(generate_query(report_indicator, year, 'Haematology'))
            end
          end
          queries
        end

        def serology_queries
          queries = []
          report_indicators = Reports::Moh::Serology.new.report_indicator
          report_years = Reports::Moh::ReportUtils::LOAD_PROCEDURE_YEARS_DATA
          report_indicators.each do |report_indicator|
            report_years.each do |year|
              queries.push(generate_query(report_indicator, year, 'Serology'))
            end
          end
          queries
        end

        def parasitology_queries
          queries = []
          report_indicators = Reports::Moh::Parasitology.new.report_indicator
          report_years = Reports::Moh::ReportUtils::LOAD_PROCEDURE_YEARS_DATA
          report_indicators.each do |report_indicator|
            report_years.each do |year|
              queries.push(generate_query(report_indicator, year, 'Parasitology'))
            end
          end
          queries
        end

        def microbiology_queries
          queries = []
          report_indicators = Reports::Moh::Microbiology.new.report_indicator
          report_years = Reports::Moh::ReportUtils::LOAD_PROCEDURE_YEARS_DATA
          report_indicators.each do |report_indicator|
            report_years.each do |year|
              queries.push(generate_query(report_indicator, year, 'Microbiology'))
            end
          end
          queries
        end
      end
    end
  end
end
