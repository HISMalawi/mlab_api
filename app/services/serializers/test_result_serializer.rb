# frozen_string_literal: true

# Serializes the test results
module Serializers
  # TestResultSerializer module
  module TestResultSerializer
    def self.serialize(test_id)
      TestResult.find_by_sql(query(test_id))
    end

    def self.query(test_id)
      <<-SQL
        SELECT
          tr.id,
          ti.name,
          tr.value,
          tr.machine_name,
          tr.result_date
        FROM
          test_results tr INNER JOIN test_indicators ti
        ON ti.id = tr.test_indicator_id AND tr.test_id = #{test_id}
          AND tr.voided = 0 AND ti.retired = 0
      SQL
    end
  end
end
