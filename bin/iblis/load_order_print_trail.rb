# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_print_trail(offset, limit, creator)
  Iblis.find_by_sql("
    SELECT
      id,
      specimen_id AS order_id,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      CASE
		WHEN printed_by = 0 THEN #{creator}
        ELSE printed_by
      END AS creator,
      CASE
        WHEN printed_by = 0 THEN #{creator}
        ELSE printed_by
      END AS  updated_by,
      CASE
        WHEN created_at = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
        ELSE created_at
      END AS created_date,
      CASE
        WHEN updated_at = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
        ELSE updated_at
      END AS updated_date
    FROM
      patient_report_print_statuses
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_print_trail_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
    patient_report_print_statuses
  ")[0]
end

ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
creator = User.first.id
Rails.logger.info('Starting to process....')
total_records = iblis_print_trail_count.count
batch_size = 10_000
offset = 0
count = total_records
loop do
  records = iblis_print_trail(offset, batch_size, creator)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Print Trail-- step(10 of 10)")
  ClientOrderPrintTrail.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
end
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")