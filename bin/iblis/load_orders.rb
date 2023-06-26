# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_orders(offset, limit, priority_id)
  Iblis.find_by_sql(
    "SELECT
    s.id,
    t.visit_id AS encounter_id,
    #{priority_id} AS priority_id,
    s.accession_number,
    s.tracking_number,
    t.requested_by,
    CASE
      WHEN s.date_of_collection = '0000-00-00 00:00:00' THEN t.time_created
      ELSE s.date_of_collection
    END AS sample_collected_time,
    s.drawn_by_name AS collected_by,
    t.created_by AS creator,
    0 AS voided,
    NULL AS voided_by,
    NULL AS voided_reason,
    NULL AS voided_date,
    t.time_created AS created_date,
    t.time_created AS updated_date,
    t.created_by AS updated_by
FROM
    specimens s
        INNER JOIN
    tests t ON t.specimen_id = s.id
    LIMIT #{limit} OFFSET #{offset}"
  )
end

def iblis_orders_with_stat(offset, limit, priority_id)
  Iblis.find_by_sql(
    "SELECT
      s.id,
      t.visit_id AS encounter_id,
      #{priority_id} AS priority_id,
      s.accession_number,
      s.tracking_number,
      t.requested_by,
      CASE
        WHEN s.date_of_collection = '0000-00-00 00:00:00' THEN t.time_created
        ELSE s.date_of_collection
      END AS sample_collected_time,
      s.drawn_by_name AS collected_by,
      t.created_by AS creator,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      t.time_created AS created_date,
      t.time_created AS updated_date,
      t.created_by AS updated_by
    FROM
    specimens s
        INNER JOIN
    tests t ON t.specimen_id = s.id
    WHERE s.priority = 'Stat'
    LIMIT #{limit} OFFSET #{offset}"
  )
end

def iblis_orders_with_stat_count
  Iblis.find_by_sql(
    "SELECT
      count(*) AS count
    FROM
    specimens s
        INNER JOIN
    tests t ON t.specimen_id = s.id
    WHERE s.priority = 'Stat'"
  )[0]
end

def iblis_orders_statuses(offset, limit, specimen_not_collected, specimen_accepted)
  Iblis.find_by_sql("
    SELECT
      distinct
      s.id AS order_id,
      CASE
        WHEN s.specimen_status_id = 1 THEN #{specimen_not_collected}
        ELSE #{specimen_accepted}
      END AS status_id,
      NULL AS status_reason_id,
      s.accepted_by AS creator,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      CASE
          WHEN s.time_accepted IS NULL THEN t.time_created
          WHEN s.time_accepted IS NULL AND t.time_created IS NULL THEN '2016-01-01 06:06:06'
          WHEN s.time_accepted = '0000-00-00 00:00:00' OR t.time_created = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
          ELSE s.time_accepted
      END AS created_date,
      CASE
          WHEN s.time_accepted IS NULL THEN t.time_created
          WHEN s.time_accepted IS NULL AND t.time_created IS NULL THEN '2016-01-01 06:06:06'
          WHEN s.time_accepted = '0000-00-00 00:00:00' OR t.time_created = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
          ELSE s.time_accepted
      END AS updated_date,
      NULL AS person_talked_to,
      s.accepted_by AS updated_by
    FROM
      specimens s
    INNER JOIN tests t ON t.specimen_id = s.id
    WHERE s.time_rejected IS NULL
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_orders_status_rejected(offset, limit, specimen_rejected)
  Iblis.find_by_sql("
    SELECT
      distinct
      s.id AS order_id,
      #{specimen_rejected} AS status_id,
      s.rejected_by AS creator,
      s.rejected_by AS updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      rr.reason AS reason,
      s.reject_explained_to AS person_talked_to,
      CASE
          WHEN s.time_rejected = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
          ELSE s.time_rejected
      END AS created_date,
      CASE
          WHEN s.time_rejected = '0000-00-00 00:00:00' THEN '2016-01-01 06:06:06'
          ELSE s.time_rejected
      END AS updated_date
    FROM
      specimens s
    INNER JOIN rejection_reasons rr ON rr.id = s.rejection_reason_id
    WHERE s.time_rejected IS NOT NULL
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_orders_stat_count
  Iblis.find_by_sql("
    SELECT
      count(distinct s.id) AS count
    FROM
      specimens s
    INNER JOIN tests t ON t.specimen_id = s.id
    WHERE s.time_rejected IS NULL
  ")[0]
end

def iblis_orders_reje_stat_count
  Iblis.find_by_sql("
    SELECT
      count(distinct s.id) AS count
    FROM
      specimens s
    INNER JOIN tests t ON t.specimen_id = s.id
    WHERE s.time_rejected IS NOT NULL
  ")[0]
end

def orders_count
  Iblis.find_by_sql('SELECT count(*) AS count from specimens s inner join tests t on t.specimen_id=s.id')[0]
end

Rails.logger.info('Starting to process....')
total_records = orders_count.count
batch_size = 10_000
offset = 0
count = total_records
priority_id = Priority.find_or_create_by(name: 'Routine').id
loop do
  records = iblis_orders(offset, batch_size, priority_id)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --ORDERS--  => (step 3 of 10)")
  unless records.empty?
    Order.upsert_all(records.map(&:attributes), returning: false)
  end
  offset += batch_size
  count -= batch_size
end

total_records = iblis_orders_with_stat_count.count
batch_size = 10_000
offset = 0
count = total_records
priority_id = Priority.find_or_create_by(name: 'Stat').id
loop do
  records = iblis_orders_with_stat(offset, batch_size, priority_id)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Update Orders--  => (step 4 of 10)")
  unless records.empty?
    Order.upsert_all(records.map(&:attributes), returning: false)
  end
  offset += batch_size
  count -= batch_size
end

total_records = iblis_orders_stat_count.count
batch_size = 10_000
offset = 0
count = total_records
specimen_not_collected = Status.find_or_create_by(name: 'specimen-not-collected').id
specimen_accepted = Status.find_or_create_by(name: 'specimen-accepted').id
specimen_rejected = Status.find_or_create_by(name: 'specimen-rejected').id
loop do
  records = iblis_orders_statuses(offset, batch_size, specimen_not_collected, specimen_accepted)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Orders Statuses--  => (step 5 of 10)")
  unless records.empty?
    OrderStatus.insert_all(records.map(&:attributes), returning: false)
  end
  offset += batch_size
  count -= batch_size
end

total_records = iblis_orders_reje_stat_count.count
batch_size = 10_000
offset = 0
count = total_records
specimen_rejected = Status.find_or_create_by(name: 'specimen-rejected').id
loop do
  records = iblis_orders_status_rejected(offset, batch_size, specimen_rejected)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Rejected Orders Statuses--  => (step 6 of 10)")
  unless records.empty?
    OrderStatus.upsert_all(records.map { |record| record.attributes.merge('status_reason_id' => StatusReason.find_or_create_by(description: record.reason).id).except('reason') }, returning: false)
  end
  offset += batch_size
  count -= batch_size
end