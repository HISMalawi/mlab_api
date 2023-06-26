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

def iblis_created_test_status(offset, limit, created_status, creator)
  Iblis.find_by_sql("
    SELECT
      t.id AS test_id,
      #{created_status} AS status_id,
      CASE
        WHEN t.created_by = 0 THEN #{creator}
        ELSE t.created_by
      END AS creator,
      CASE
        WHEN t.created_by = 0 THEN #{creator}
        ELSE t.created_by
      END AS  updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      NULL AS status_reason_id,
      NULL AS person_talked_to,
      t.time_created AS created_date,
      t.time_created AS updated_date
    FROM
      tests t
    WHERE t.time_created IS NOT NULL
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_started_test_status(offset, limit, started_status, creator)
  Iblis.find_by_sql("
    SELECT
      t.id AS test_id,
      #{started_status} AS status_id,
      CASE
        WHEN t.tested_by = 0 THEN #{creator}
        ELSE t.tested_by
      END AS creator,
      CASE
        WHEN t.tested_by = 0 THEN #{creator}
        ELSE t.tested_by
      END AS  updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      NULL AS status_reason_id,
      NULL AS person_talked_to,
      t.time_started AS created_date,
      t.time_started AS updated_date
    FROM
      tests t
    WHERE t.time_started IS NOT NULL
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_completed_test_status(offset, limit, completed_status, creator)
  Iblis.find_by_sql("
    SELECT
      t.id AS test_id,
      #{completed_status} AS status_id,
      CASE
        WHEN t.tested_by = 0 THEN #{creator}
        ELSE t.tested_by
      END AS creator,
      CASE
        WHEN t.tested_by = 0 THEN #{creator}
        ELSE t.tested_by
      END AS  updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      NULL AS status_reason_id,
      NULL AS person_talked_to,
      t.time_completed AS created_date,
      t.time_completed AS updated_date
    FROM
      tests t
    WHERE t.time_completed IS NOT NULL
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_verified_test_status(offset, limit, verified_status, creator)
  Iblis.find_by_sql("
    SELECT
      t.id AS test_id,
      #{verified_status} AS status_id,
      CASE
        WHEN t.verified_by = 0 THEN #{creator}
        ELSE t.verified_by
      END AS creator,
      CASE
        WHEN t.verified_by = 0 THEN #{creator}
        ELSE t.verified_by
      END AS  updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date,
      NULL AS status_reason_id,
      NULL AS person_talked_to,
      t.time_verified AS created_date,
      t.time_verified AS updated_date
    FROM
      tests t
    WHERE t.time_verified IS NOT NULL
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

creator = User.first.id
Rails.logger.info('Starting to process....')
total_records = iblis_test_count.count
batch_size = 10_000
offset = 0
count = total_records
loop do
  records = iblis_test(offset, batch_size)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --TESTS-- step(7 of 10)")
  Test.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
end

# process all test status records
total_records = iblis_test_count.count
batch_size = 10_000
offset = 0
count = total_records
created_status = Status.find_or_create_by(name: 'pending').id
started_status = Status.find_or_create_by(name: 'started').id
completed_status = Status.find_or_create_by(name: 'completed').id
verified_status = Status.find_or_create_by(name: 'verified').id
loop do
  records = []
  created_records = iblis_created_test_status(offset, batch_size, created_status, creator)
  started_records = iblis_started_test_status(offset, batch_size, started_status, creator)
  completed_records = iblis_completed_test_status(offset, batch_size, completed_status, creator)
  verified_records = iblis_verified_test_status(offset, batch_size, verified_status, creator)
  records << started_records unless started_records.empty?
  records << created_records unless created_records.empty?
  records << completed_records unless completed_records.empty?
  records << verified_records unless verified_records.empty?
  break if records.empty?
  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --TESTS STATUSES-- step(8 of 10)")
  Parallel.map(records, in_processes: 4) do |record|
    TestStatus.upsert_all(record.map(&:attributes), returning: false) unless record.empty?
  end
  offset += batch_size
  count -= batch_size
end


# Handle not done status
