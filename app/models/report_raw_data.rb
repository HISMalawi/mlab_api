# frozen_string_literal: true

# Report raw data model
class ReportRawData < ApplicationRecord
  self.table_name = 'report_raw_data'

  after_create :update_moh_report_data

  def self.insert_data(test_id)
    query = <<-SQL
    SELECT
      CONCAT(t.id, ti.id, cts.status_id) AS id,
      t.id AS test_id,
      DATE(t.created_date) AS created_date,
      tt.name AS test_type,
      spt.name AS specimen,
      cts.status_id,
      cts.name AS status_name,
      cos.status_id AS order_status_id,
      cos.name AS order_status_name,
      ti.id AS test_indicator_id,
      ti.name AS test_indicator_name,
      TRIM(tr.value) AS result,
      p.date_of_birth AS dob,
      fs.name AS ward,
      TRIM(dp.name) AS department,
      ets.name AS encounter_type,
      NOW() AS updated_at
    FROM tests t
    INNER JOIN test_types tt ON t.test_type_id = tt.id AND t.id = #{test_id}#{'  '}
    INNER JOIN specimen spt ON t.specimen_id = spt.id
    INNER JOIN current_test_status cts ON cts.test_id = t.id AND cts.status_id#{' '}
    INNER JOIN current_order_status cos ON cos.order_id = t.order_id AND cos.status_id IN (10, 11)
    INNER JOIN test_indicators ti ON ti.test_type_id = tt.id
    LEFT JOIN test_results tr ON tr.test_id = t.id AND ti.id = tr.test_indicator_id AND tr.value IS NOT NULL#{'   '}
      AND tr.value NOT IN ('', '0') AND tr.voided = 0
    INNER JOIN orders o ON o.id = t.order_id AND o.voided = 0
    INNER JOIN encounters e ON e.id = o.encounter_id AND e.voided = 0
    INNER JOIN encounter_types ets ON e.encounter_type_id = ets.id
    INNER JOIN clients c ON c.id = e.client_id
    INNER JOIN people p ON p.id = c.person_id
    INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
    INNER JOIN departments dp ON dp.id = tt.department_id
    WHERE t.voided = 0 AND t.id = #{test_id}
    SQL
    records = find_by_sql(query)
    ReportRawData.upsert_all(records.map(&:attributes), returning: false)
    ReportRawData.where(test_id: test_id).each(&:update_moh_report_data)
  end

  def update_moh_report_data
    creates_date = self.created_date.nil? ? '' : self.created_date
    UpdateMohReportDataJob.perform_at(1.minutes.from_now, created_date.strftime("%Y-%m-%d").to_s)
  end
end
