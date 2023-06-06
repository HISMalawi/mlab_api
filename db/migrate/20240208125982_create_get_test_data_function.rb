class CreateGetTestDataFunction < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      
      CREATE PROCEDURE get_test_data()
      BEGIN
        DROP TABLE IF EXISTS moh_report_mat_view;
        CREATE TABLE moh_report_mat_view (
          id INT PRIMARY KEY,
          test_id INT,
          created_date DATE,
          test_type VARCHAR(255),
          status_id INT,
          status_name VARCHAR(255),
          test_indicator_name VARCHAR(255),
          result VARCHAR(255),
          dob DATE,
          ward VARCHAR(255),
          department VARCHAR(255),
          encounter_type VARCHAR(255)
        );

        INSERT INTO moh_report_mat_view
        SELECT
          tr.id AS id,
          t.id AS test_id,
          DATE(t.created_date) AS created_date,
          tt.name AS test_type,
          cts.status_id,
          cts.name AS status_name,
          ti.name AS test_indicator_name,
          tr.value AS result,
          p.date_of_birth AS dob,
          fs.name AS ward,
          TRIM(dp.name) AS department,
          ets.name AS encounter_type
        FROM tests t
        INNER JOIN test_types tt ON t.test_type_id = tt.id
        INNER JOIN current_test_status cts ON cts.test_id = t.id AND cts.status_id IN (4, 5)
        INNER JOIN test_indicators ti ON ti.test_type_id = tt.id
        INNER JOIN test_results tr ON tr.test_id = t.id AND ti.id = tr.test_indicator_id AND tr.value IS NOT NULL AND tr.value <> '' AND tr.voided = 0
        INNER JOIN orders o ON o.id = t.order_id AND o.voided = 0
        INNER JOIN encounters e ON e.id = o.encounter_id AND e.voided = 0
        INNER JOIN encounter_types ets ON e.encounter_type_id = ets.id
        INNER JOIN clients c ON c.id = e.client_id
        INNER JOIN people p ON p.id = c.person_id
        INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
        INNER JOIN departments dp ON dp.id = tt.department_id
        WHERE t.voided = 0;

        SELECT * FROM moh_report_mat_view;
      END
    SQL
  end

  def down
    execute "DROP PROCEDURE IF EXISTS get_test_data"
    execute "DROP TABLE IF EXISTS moh_report_mat_view"
  end
end
