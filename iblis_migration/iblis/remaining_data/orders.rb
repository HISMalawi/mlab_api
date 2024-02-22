# frozen_string_literal: true

module Orders
  class << self
    # frozen_string_literal: true

    Rails.logger = Logger.new($stdout)

    def iblis_orders(order_id, priority_id, specimen_not_collected, specimen_accepted, specimen_rejected)
      Iblis.find_by_sql(
        "SELECT
    s.id,
    t.visit_id AS encounter_id,
    #{priority_id} AS priority_id,
    s.accession_number,
    s.tracking_number,
    t.requested_by,
    CASE
        WHEN s.date_of_collection = '0000-00-00 00:00:00' OR s.date_of_collection IS NULL THEN t.time_created
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
    t.created_by AS updated_by,
    CASE
      WHEN s.specimen_status_id = 1 THEN #{specimen_not_collected}
      WHEN s.specimen_status_id = 2 THEN #{specimen_accepted}
      ELSE #{specimen_rejected}
    END AS status_id
FROM
    specimens s
        INNER JOIN
    tests t ON t.specimen_id = s.id
    WHERE s.id > #{order_id}"
      )
    end

    def iblis_orders_with_stat(order_id, priority_id, specimen_not_collected, specimen_accepted, specimen_rejected)
      Iblis.find_by_sql(
        "SELECT
      s.id,
      t.visit_id AS encounter_id,
      #{priority_id} AS priority_id,
      s.accession_number,
      s.tracking_number,
      t.requested_by,
      CASE
        WHEN s.date_of_collection = '0000-00-00 00:00:00' OR s.date_of_collection IS NULL THEN t.time_created
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
      t.created_by AS updated_by,
      CASE
      WHEN s.specimen_status_id = 1 THEN #{specimen_not_collected}
      WHEN s.specimen_status_id = 2 THEN #{specimen_accepted}
      ELSE #{specimen_rejected}
    END AS status_id
    FROM
    specimens s
        INNER JOIN
    tests t ON t.specimen_id = s.id
    WHERE s.priority = 'Stat' AND s.id > #{order_id}"
      )
    end

    def iblis_orders_statuses(order_id, specimen_not_collected, specimen_accepted)
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
        WHEN s.time_accepted = '0000-00-00 00:00:00' OR s.time_accepted IS NULL THEN t.time_created
        ELSE s.time_accepted
      END AS created_date,
      CASE
          WHEN s.time_accepted = '0000-00-00 00:00:00' OR s.time_accepted IS NULL THEN t.time_created
          ELSE s.time_accepted
      END AS updated_date,
      NULL AS person_talked_to,
      s.accepted_by AS updated_by
    FROM
      specimens s
    INNER JOIN tests t ON t.specimen_id = s.id
    WHERE s.time_rejected IS NULL AND s.id > #{order_id}
  ")
    end

    def iblis_orders_status_rejected(order_id, specimen_rejected)
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
        WHEN s.time_rejected = '0000-00-00 00:00:00' OR s.time_rejected IS NULL THEN t.time_created
        ELSE s.time_rejected
      END AS created_date,
      CASE
          WHEN s.time_rejected = '0000-00-00 00:00:00' OR s.time_rejected IS NULL THEN t.time_created
          ELSE s.time_rejected
      END AS updated_date
    FROM
      specimens s
    INNER JOIN tests t ON t.specimen_id = s.id
    INNER JOIN rejection_reasons rr ON rr.id = s.rejection_reason_id
    WHERE s.time_rejected IS NOT NULL AND s.id > #{order_id}
  ")
    end

    def orders_count(order_id)
      Iblis.find_by_sql("SELECT count(*) AS count from specimens s inner join tests t on t.specimen_id=s.id WHERE s.id > #{order_id}")[0].count
    end

    def fix_people(records)
      user = User.first.id
      records.map!(&:attributes).map do |record|
        record[:creator] = user unless User.exists?(id: record[:creator])
        record
      end
    end

    def process_orders(order_id)
      Rails.logger = Logger.new(STDOUT)
      total_records = orders_count(order_id)
      Rails.logger.info("Processing orders #{total_records} : Remaining - 0 --Orders-- (step 3 of 8)")
      priority_id = Priority.find_or_create_by(name: 'Routine').id
      specimen_not_collected = Status.find_or_create_by(name: 'specimen-not-collected').id
      specimen_accepted = Status.find_or_create_by(name: 'specimen-accepted').id
      specimen_rejected = Status.find_or_create_by(name: 'specimen-rejected').id
      records = iblis_orders(order_id, priority_id, specimen_not_collected, specimen_accepted, specimen_rejected)
      Order.upsert_all(records.map(&:attributes), returning: false) unless records.empty?

      priority_id = Priority.find_or_create_by(name: 'Stat').id
      st_records = iblis_orders_with_stat(order_id, priority_id, specimen_not_collected, specimen_accepted,
                                       specimen_rejected)
      Order.upsert_all(st_records.map(&:attributes), returning: false) unless st_records.empty?

      s_records = iblis_orders_statuses(order_id, specimen_not_collected, specimen_accepted)
      OrderStatus.insert_all(fix_people(s_records), returning: false) unless s_records.empty?

      r_records = iblis_orders_status_rejected(order_id, specimen_rejected)
      OrderStatus.upsert_all(r_records.map do |record|
                               record.attributes.merge('status_reason_id' => StatusReason.find_or_create_by(description: record.reason).id).except('reason')
                             end, returning: false) unless r_records.empty?
    end
  end
end
