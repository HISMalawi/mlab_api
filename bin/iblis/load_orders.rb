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
    s.date_of_collection AS sample_collected_time,
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
      s.date_of_collection AS sample_collected_time,
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

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --ORDERS--  => (step 2 of 9)")
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

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Update Orders--  => (step 3 of 9)")
  unless records.empty?
    Order.upsert_all(records.map(&:attributes), returning: false)
  end
  offset += batch_size
  count -= batch_size
end


# Handle the case of test status of the orders
