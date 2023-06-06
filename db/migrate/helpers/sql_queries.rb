# frozen_String_literal: true

require_relative 'haematology/indicator_calculations'

# SQL queries for creating counts of indicators per created_date
module SqlQueries
  include Haematology::IndicatorCalculations
  def generate_query(report_indicator, year)
    parameterized_name = report_indicator.parameterize.underscore
    <<-SQL
          SELECT created_date AS created_date, '#{report_indicator}' AS indicator,
          #{send("calculate_#{parameterized_name}")} AS total, department
          FROM moh_report_mat_view
          WHERE YEAR(created_date) = '#{year}'
          GROUP BY created_date, department
    SQL
  end

  def haematology_queries
    queries = []
    report_indicators = Reports::Moh::ReportUtils::HEMATOLOGY_REPORT_INDICATORS
    report_years = Reports::Moh::ReportUtils::LOAD_PROCEDURE_YEARS_DATA
    report_indicators.each do |report_indicator|
      report_years.each do |year|
        queries.push(generate_query(report_indicator, year))
      end
    end
    queries
  end
end

