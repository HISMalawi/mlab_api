class MohReportMatViewJob
  include Sidekiq::Job

  def perform(test_id, result_id)
    ActiveRecord::Base.connection.execute(<<-SQL
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
      INNER JOIN test_types tt ON t.test_type_id = tt.id AND t.id = #{test_id}
      INNER JOIN current_test_status cts ON cts.test_id = t.id AND cts.status_id IN (4, 5)
      INNER JOIN test_indicators ti ON ti.test_type_id = tt.id AND t.id = #{test_id}
      INNER JOIN test_results tr ON tr.test_id = t.id AND ti.id = tr.test_indicator_id AND tr.value IS NOT NULL AND tr.value <> '' AND tr.voided = 0 AND t.id = #{test_id} AND tr.id = #{result_id}
      INNER JOIN orders o ON o.id = t.order_id AND o.voided = 0 AND t.id = #{test_id}
      INNER JOIN encounters e ON e.id = o.encounter_id AND e.voided = 0
      INNER JOIN encounter_types ets ON e.encounter_type_id = ets.id
      INNER JOIN clients c ON c.id = e.client_id
      INNER JOIN people p ON p.id = c.person_id
      INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
      INNER JOIN departments dp ON dp.id = tt.department_id
      WHERE t.voided = 0 AND t.id = #{test_id};
    SQL
    )
  end
end
