# frozen_string_literal: true

module PrintTrails
  class << self
    def iblis_print_trail(order_id, creator)
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
          COALESCE(DATE(created_at), '2016-05-23 06:47:12.000000') AS created_date,
          COALESCE(DATE(created_at), '2016-05-23 06:47:12.000000') AS updated_date
        FROM
          patient_report_print_statuses WHERE specimen_id > #{order_id}
      ")
    end

    def process_print_trails(order_id)
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
      creator = User.first.id
      records = iblis_print_trail(order_id, creator)
      Rails.logger.info("Processing Print Trail #{records.count}: Remaining - 0 --Print Trail-- step(8 of 8)")
      ClientOrderPrintTrail.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
    end
  end
end
