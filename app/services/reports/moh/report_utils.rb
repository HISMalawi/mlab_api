# frozen_string_literal: true

# Module utils that help in generating reports
module Reports
  # Generates blood bank reports
  module Moh
    # Haematology report class
    module ReportUtils
      class << self
        def report_years
          range = []
          max_year = Test.maximum(:created_date)
          unless max_year.nil?
            min_year = Test.minimum(:created_date).year
            range = (min_year.to_s..max_year.year.to_s).to_a
          end
          range
        end
      end
    end
  end
end
