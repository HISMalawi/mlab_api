# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_orders(offset, limit)
  Iblis.find_by_sql(
    "SELECT DISTINCT
    s.id,
    t.visit_id AS encounter_id,
    s.priority,
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

def orders_count
  Iblis.find_by_sql('SELECT count(*) AS count from specimens s inner join tests t on t.specimen_id=s.id')[0]
end

Rails.logger.info('Starting to process....')
total_records = orders_count.count
batch_size = 10_000
offset = 0
count = total_records
loop do
  records = iblis_orders(offset, batch_size)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count}  => (step 2 of 7)")
  unless records.empty?
    Order.upsert_all(records.map do |record|
                       record.attributes.merge('priority_id' => Priority.find_or_create_by(name: record.priority).id)
                       .except('priority')
                     end, returning: false)
  end
  offset += batch_size
  count -= batch_size
end

# Handle the case of test status of the orders
