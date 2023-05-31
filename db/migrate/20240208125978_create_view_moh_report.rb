# frozen_string_literal: true

# create a new view
class CreateViewMohReport < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      CREATE VIEW moh_report AS
      SELECT
        t.id AS test_id,
        t.created_date,
        tt.name AS test_type,
        cts.status_id,
        cts.name AS status_name,
        ti.name AS test_indicator_name,
        tr.value AS result,
        p.date_of_birth AS dob,
        fs.name AS ward,
        dp.name AS department
      FROM
        tests t
        INNER JOIN test_types tt ON t.test_type_id = tt.id
        INNER JOIN current_test_status cts ON cts.test_id = t.id
        INNER JOIN test_indicators ti ON ti.test_type_id = tt.id
        INNER JOIN test_results tr ON tr.test_id = t.id AND ti.id = tr.test_indicator_id
        INNER JOIN orders o ON o.id = t.order_id
        INNER JOIN encounters e ON e.id = o.encounter_id
        INNER JOIN clients c ON c.id = e.client_id
        INNER JOIN people p ON p.id = c.person_id
        INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
        INNER JOIN departments dp ON dp.id = tt.department_id
      WHERE
        tr.value IS NOT NULL AND tr.value <> '' AND cts.status_id in (4, 5)
    SQL
  end
end
