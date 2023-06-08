# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Biochemistry indicators
      module BiochemistryIndicatorCalculations
        def calculate_blood_glucose
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Glucose', 'Glucose (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND specimen = 'Blood' AND test_indicator_name IN ('Glucose', 'Glu','Glu-G')
              THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
