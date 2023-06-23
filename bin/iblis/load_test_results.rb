# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_test_result(offset, limit, creator)
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
      CASE
        WHEN tr.time_entered = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
        ELSE tr.time_entered
      END AS created_date,
      CASE
        WHEN tr.time_entered = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
        ELSE tr.time_entered
      END AS updated_date
    FROM
      test_results tr
          INNER JOIN
      tests t ON tr.test_id = t.id
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_test_result_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
      test_results
  ")[0]
end

creator = User.first.id
Rails.logger.info('Starting to process....')
total_records = iblis_test_result_count.count
batch_size = 50_000
offset = 0
count = total_records
loop do
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
  records = iblis_test_result(offset, batch_size, creator)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --TEST RESULTS-- step(9 of 10)")
  TestResult.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")
end
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")