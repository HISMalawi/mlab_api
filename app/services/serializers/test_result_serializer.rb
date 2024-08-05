# frozen_string_literal: true

# Serializes the test results
module Serializers
  # TestResultSerializer module
  module TestResultSerializer
    def self.serialize(test_id, test_indicator_id: nil)
      query(test_id, test_indicator_id)
    end

    def self.query(test_id, test_indicator_id)
      test_results = TestResult.joins(:test_indicator).where(test_id:)
                               .select('test_results.id, name, value, machine_name, result_date')
      test_results = test_results.where(test_indicator_id:) if test_indicator_id.present?
      test_results
    end
  end
end
