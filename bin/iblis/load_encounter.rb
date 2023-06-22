Rails.logger = Logger.new(STDOUT)

def get_records(offset, limit)
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
            FROM tests
            ORDER BY visit_id
            LIMIT #{limit} OFFSET #{offset}
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

def get_count
  Iblis.find_by_sql(
    "SELECT
      count(visit_id) as count
    FROM
        (
            SELECT DISTINCT visit_id, time_verified, created_by
            FROM tests
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
            AND ovw.visit_type = v.visit_type"
  )[0]
end
Rails.logger.info("Starting to process....")
total_records = get_count.count
batch_size = 10000
offset = 0
count = total_records
loop do
  records = get_records(offset, batch_size)
  break if records.empty?
  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count}  --Encounters-- (step 1 of 9)")
  Encounter.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
end


# Handle the case of referal, update the record with necessary site information for facility and destination


