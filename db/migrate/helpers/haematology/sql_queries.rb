# frozen_String_literal: true

require_relative 'indicator_calculations'

# Queries for creating counts of indicators per created_date for haematology department
module Haematology
  # SQL queries for creating counts of indicators per created_date
  module SqlQueries
    include IndicatorCalculations
    def generate_query(report_indicator)
      parameterized_name = report_indicator.parameterize.underscore
      <<-SQL
            SELECT created_date AS created_date, '#{parameterized_name}' AS indicator,
            #{send("calculate_#{parameterized_name}")} AS total, department AS department
            FROM moh_report
            WHERE department = 'Haematology'
            GROUP BY created_date
      SQL
    end

    def haematology_queries
      queries = []
      report_indicators = Reports::Moh::Haematology.new.report_indicator
      report_indicators.each do |report_indicator|
        queries.push(generate_query(report_indicator))
      end
      queries
    end
  end
end
