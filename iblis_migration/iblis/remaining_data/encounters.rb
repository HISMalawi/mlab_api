# frozen_string_literal: true

# load remaining encounters
module Encounters
  class << self
    def remaining_encounters(test_id)
      Iblis.find_by_sql(
        "SELECT
          t.visit_id AS id,
          v.patient_id AS client_id,
          NULL AS facility_id,
          NULL AS destination_id,
          ovw.ward_id AS facility_section_id,
          v.created_at AS start_date,
          t.time_verified AS end_date,
          0 AS voided,
          NULL AS voided_by,
          NULL AS voided_reason,
          NULL AS voided_date,
          t.created_by AS creator,
          v.created_at AS created_date,
          v.updated_at AS updated_date,
          ovw.visit_type_id AS encounter_type_id,
          t.created_by AS updated_by
        FROM
            (
                SELECT DISTINCT visit_id, time_verified, created_by
                FROM tests WHERE id > #{test_id}
                ORDER BY visit_id
            ) AS t
            INNER JOIN visits v ON v.id = t.visit_id
            LEFT JOIN (
                SELECT
                    w.name,
                    vw.visit_type_id,
                    vw.ward_id,
                    iv.name visit_type
                FROM
                    wards w
                    INNER JOIN visittype_wards vw ON vw.ward_id = w.id
                    INNER JOIN visit_types iv ON iv.id = vw.visit_type_id
            ) ovw ON ovw.name = v.ward_or_location
                AND ovw.visit_type = v.visit_type
        ORDER BY t.visit_id"
      )
    end

    def process_encounters(test_id)
      Rails.logger = Logger.new(STDOUT)
      records = remaining_encounters(test_id)
      Rails.logger.info("Processing encounters : Remaining - #{records.count}  --Encounters-- (step 2 of 8)")
      Encounter.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
    end
  end
end
