# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_unsync_orders(offset, limit)
  Iblis.find_by_sql("
    SELECT
      ou.id,
      ou.specimen_id AS test_or_order_id,
      ou.data_not_synced,
      CASE
            WHEN  ou.data_level = 'specimen' THEN 'order'
        ELSE ou.data_level
      END AS data_level,
      CASE
        WHEN ou.sync_status = 'not-synced' THEN 0
        ELSE 1
      END AS sync_status,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      NULL AS creator,
      NULL updated_by,
      ou.created_at AS created_date,
      ou.updated_at AS updated_date
    FROM
      unsync_orders ou
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_unsync_orders_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
      unsync_orders
  ")[0]
end

Rails.logger.info('Starting to process....')
total_records = iblis_unsync_orders_count.count
batch_size = 50_000
offset = 0
count = total_records
loop do
  records = iblis_unsync_orders(offset, batch_size)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --UNSYNC ORDERS-- step(11 of 11)")
  UnsyncOrder.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
end
