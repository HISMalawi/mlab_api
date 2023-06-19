Rails.logger = Logger.new(STDOUT)

def get_records(offset, limit)
  Iblis.find_by_sql(
    "SELECT DISTINCT
    s.id,
    t.visit_id AS encounter_id,
    s.accession_number,
    s.tracking_number,
    t.requested_by,
    s.date_of_collection AS sample_collected_time,
    s.drawn_by_name AS collectd_by,
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

def get_count
  Iblis.find_by_sql("SELECT count(*) AS count from specimens s inner join tests t on t.specimen_id=s.id")[0]
end

Rails.logger.info("Starting to process....")
total_records = get_count.count
batch_size = 1000
offset = 0
count = total_records
loop do
  records = get_records(offset, batch_size)
  break if records.empty?
  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count}  => (step 2 of 7)")
  Order.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= 1000
end


# Handle the case of test status of the orders


