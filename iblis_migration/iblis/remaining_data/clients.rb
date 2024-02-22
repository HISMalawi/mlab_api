# frozen_string_literal: true

# Load clients starting from last created client
module Clients
  class << self
    def remaining_clients(client_id)
      Iblis.find_by_sql("
          SELECT
            p.id AS id,
            p.id AS person_id,
            NULL AS uuid,
            IF(p.deleted_at IS NOT NULL, 1, 0) AS voided,
            NULL AS voided_by,
            NULL AS voided_reason,
            NULL AS voided_reason,
            IF(p.created_by = 0, 1, p.created_by) AS creator,
            p.created_at AS created_date,
            p.updated_at AS updated_date,
            IF(p.created_by = 0, 1, p.created_by) AS updated_by
          FROM patients p WHERE p.id > #{client_id}
        ")
    end

    def remaining_people(client_id)
      Iblis.find_by_sql("
        SELECT
          p.id AS id,
            SUBSTRING_INDEX(SUBSTRING_INDEX(p.name, ' ', 1), ' ', -1) AS first_name,
            '' AS middle_name,
            SUBSTRING_INDEX(p.name, ' ', -1) AS last_name,
            CASE
                WHEN p.gender = 0 THEN 'M'
                WHEN p.gender = 1 THEN 'F'
            END AS sex,
            COALESCE(p.dob, '0000-00-00') AS date_of_birth,
            p.dob_estimated AS birth_date_estimated,
          IF(p.deleted_at IS NOT NULL, 1, 0) AS voided,
            NULL AS voided_by,
            NULL AS voided_reason,
            NULL AS voided_reason,
          IF(p.created_by = 0, 1, p.created_by) AS creator,
            p.created_at AS created_date,
            p.updated_at AS updated_date,
          IF(p.created_by = 0, 1, p.created_by)  AS updated_by,
          p.first_name_code AS first_name_soundex,
          p.last_name_code AS last_name_soundex
        FROM patients p WHERE p.id > #{client_id}
      ")
    end

    def clients_count(client_id)
      Iblis.find_by_sql("
        SELECT
         count(*) AS count
        FROM patients p WHERE p.id > #{client_id}
      ")[0].count
    end

    def fix_people(records)
      user = User.first.id
      records.map!(&:attributes).map do |record|
        record[:creator] = user unless User.exists?(id: record[:creator])
        record
      end
    end

    def process_clients(client_id)
      Rails.logger = Logger.new(STDOUT)
      Rails.logger.info('Starting to process....')
      total_records = clients_count(client_id)
      c_records = remaining_clients(client_id)
      records = remaining_people(client_id)
      Rails.logger.info("Processing records #{total_records}: Remaining - 0 --CLIENTS-- step(1 of 8)")
      Person.upsert_all(fix_people(records), returning: false) unless records.empty?
      Client.upsert_all(fix_people(c_records), returning: false) unless c_records.empty?
    end
  end
end
