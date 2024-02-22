# frozen_string_literal: true

module Tests
  class << self
    def iblis_test(test_id)
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
          t.time_created AS updated_date,
          t.test_status_id AS status_id
        FROM
          specimens s
        INNER JOIN
          tests t ON s.id = t.specimen_id
              LEFT JOIN
          test_panels tp ON tp.id = t.panel_id
        WHERE t.id > #{test_id}
      ")
    end

    def iblis_created_test_status(test_id, created_status, creator)
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
        WHERE t.time_created IS NOT NULL AND t.id > #{test_id}
      ")
    end

    def iblis_started_test_status(test_id, started_status, creator)
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
        WHERE t.time_started IS NOT NULL AND t.id > #{test_id}
      ")
    end

    def iblis_completed_test_status(test_id, completed_status, creator)
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
        WHERE t.time_completed IS NOT NULL AND t.id > #{test_id}
      ")
    end

    def iblis_verified_test_status(test_id, verified_status, creator)
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
        WHERE t.time_verified IS NOT NULL AND t.id > #{test_id}
      ")
    end

    def process_tests(test_id)
      Rails.logger = Logger.new(STDOUT)
      creator = User.first.id
      records = iblis_test(test_id)
      total_records = records.count
      Rails.logger.info("Processing tests #{total_records}: Remaining - 0 --TESTS-- step(4 of 8)")
      Test.upsert_all(records.map(&:attributes), returning: false) unless records.empty?

      records = []
      created_status = Status.find_or_create_by(name: 'pending').id
      started_status = Status.find_or_create_by(name: 'started').id
      completed_status = Status.find_or_create_by(name: 'completed').id
      verified_status = Status.find_or_create_by(name: 'verified').id
      created_records = iblis_created_test_status(test_id, created_status, creator)
      started_records = iblis_started_test_status(test_id, started_status, creator)
      completed_records = iblis_completed_test_status(test_id, completed_status, creator)
      verified_records = iblis_verified_test_status(test_id, verified_status, creator)
      records << started_records unless started_records.empty?
      records << created_records unless created_records.empty?
      records << completed_records unless completed_records.empty?
      records << verified_records unless verified_records.empty?
      Rails.logger.info("Processing test statuses  #{records.length}: Remaining - 0 --TESTS STATUSES-- step(5 of 8)")
      Parallel.map(records, in_processes: 4) do |record|
        TestStatus.upsert_all(record.map(&:attributes), returning: false) unless record.empty?
      end
    end
  end
end
