# frozen_string_literal: true

# app/services/sql/test.rb
module Sql
  # SQL Query for test given test ids e.g (1,2,3,4,5)
  module Test
    def self.query(tests_ids)
      <<-SQL
        SELECT
          t.id,
          t.order_id,
          t.voided,
          t.test_type_id,
          c.id AS patient_no,
          p.first_name,
          p.middle_name,
          p.last_name,
          p.sex,
          o.requested_by,
          p.date_of_birth,
          p.birth_date_estimated,
          o.id AS order_id,
          o.accession_number,
          o.tracking_number,
          et.name AS request_origin,
          t.created_date,
          t.test_panel_id,
          tp.name AS test_panel_name,
          tt.name AS test_type,
          fs.name AS requesting_ward,
          ost.id AS o_status_id,
          ost.name AS o_status,
          tst.id AS t_status_id,
          tst.name AS t_status,
          sp.name AS specimen,
          sp.id AS specimen_id,
          t.lab_location_id,
          srs.description AS rejected_reason
        FROM
          tests t
              INNER JOIN
          test_types tt ON tt.id = t.test_type_id
              AND tt.retired = 0
              INNER JOIN
          specimen sp ON t.specimen_id = sp.id AND sp.retired = 0
              INNER JOIN
          orders o ON t.order_id = o.id AND o.voided = 0
              AND t.voided = 0
              INNER JOIN
          encounters e ON e.id = o.encounter_id AND e.voided = 0
              LEFT JOIN
          encounter_types et ON e.encounter_type_id = et.id AND et.voided = 0
              LEFT JOIN
          facility_sections fs ON fs.id = e.facility_section_id
              INNER JOIN
          clients c ON c.id = e.client_id AND c.voided = 0
              INNER JOIN
          people p ON p.id = c.person_id AND p.voided = 0
              LEFT JOIN
          test_panels tp ON tp.id = t.test_panel_id AND tp.retired = 0
              INNER JOIN
          statuses tst ON tst.id = t.status_id
              LEFT JOIN 
          test_statuses tss ON tss.test_id = t.id
            LEFT JOIN 
          status_reasons srs ON srs.id = tss.status_reason_id
            INNER JOIN 
          statuses ost ON ost.id = o.status_id
            WHERE t.id IS NOT NULL AND t.id IN #{tests_ids} ORDER BY t.id DESC
      SQL
    end
  end
end
