# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_test(offset, limit)
  Iblis.find_by_sql("
    SELECT
      t.id,
      s.id AS order_id,
      s.specimen_type_id AS specimen_id,
      t.test_type_id,
      tp.panel_type_id AS test_panel_id,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      t.created_by AS creator,
      t.created_by AS updated_by,
      t.time_created AS created_date,
    t.time_created AS updated_date
    FROM
      specimens s
    INNER JOIN
      tests t ON s.id = t.specimen_id
          LEFT JOIN
      test_panels tp ON tp.id = t.panel_id
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_test_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
      tests t
  ")[0]
end

Rails.logger.info('Starting to process....')
total_records = iblis_test_count.count
batch_size = 1_000
offset = 0
count = total_records
loop do
  records = iblis_test(offset, batch_size)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --TESTS-- step(4 of 9)")
  Test.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
end
