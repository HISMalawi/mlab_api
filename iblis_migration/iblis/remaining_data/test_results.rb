# frozen_string_literal: true

# load remaining test results
module TestResults
  class << self
    def iblis_test_result(test_id, creator)
      Iblis.find_by_sql("
        SELECT
          tr.id,
          tr.test_id,
          tr.measure_id AS test_indicator_id,
          tr.result AS value,
          tr.device_name AS machine_name,
          tr.time_entered AS result_date,
          0 AS voided,
          NULL AS voided_by,
          NULL AS voided_reason,
          NULL AS voided_date,
          CASE
                WHEN t.tested_by = 0 THEN #{creator}
            ELSE t.tested_by
          END AS creator,
          CASE
            WHEN t.tested_by = 0 THEN #{creator}
            ELSE t.tested_by
          END AS  updated_by,
          tr.time_entered AS created_date,
          tr.time_entered AS updated_date
        FROM
          test_results tr
              INNER JOIN
          tests t ON tr.test_id = t.id
        WHERE t.id > #{test_id}
      ")
    end

    def process_test_results(test_id)
      Rails.logger = Logger.new(STDOUT)
      ActiveRecord::Base.connection.execute("SET sql_mode='NO_ZERO_DATE'")
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
      creator = User.first.id
      records = iblis_test_result(test_id, creator)
      total_records = records.count
      Rails.logger.info("Processing test_results #{total_records}: Remaining - 0 --TEST RESULTS-- step(5 of 8)")
      TestResult.upsert_all(records.map(&:attributes), returning: false) unless records.empty?

      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
      ActiveRecord::Base.connection.execute("SET sql_mode=''")
    end
  end
end
