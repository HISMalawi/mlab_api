require 'csv'
module WhonetService
  class WhoNet
    def initialize(start_date, end_date)
      @start_date = start_date.to_date.beginning_of_day
      @end_date = end_date.to_date.end_of_day
      @site_origin = GlobalService.current_location.name
      @data = Report.find_by_sql("
          SELECT
            '#{@site_origin}' AS laboratory,
            p.first_name, p.last_name, p.sex AS gender, p.date_of_birth AS dob,
            fs.name AS ward_or_location, et.name AS ward_type, dt.name AS department,
            o.accession_number, s.name AS specimen_type,
            o.requested_by, t.id AS test_id,
            tt.name as test_type,
            t.created_date AS date_registered,
            MAX(CASE WHEN ts.status_id = 3 THEN ts.created_date ELSE '' END) AS time_started,
            MAX(
              CASE WHEN ts.status_id = 5 THEN ts.created_date
                WHEN ts.status_id = 4 THEN ts.created_date
              ELSE '' END
            ) AS time_verified,
            ds.organism_id,
            MAX(CASE
              WHEN tr.value = '0' OR tr.value IS NULL THEN NULL
              WHEN UPPER(tr.value) = 'GROWTH' AND o2.id IS NOT NULL THEN o2.name
              ELSE tr.value
            END) AS organism,
            MAX(CASE WHEN d.name = 'Amoxicillin/Clavulanate' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Amoxicillin/Clavulanate`,
            MAX(CASE WHEN d.name = 'Ampicillin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ampicillin`,
            MAX(CASE WHEN d.name = 'Ceftriaxone' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ceftriaxone`,
            MAX(CASE WHEN d.name = 'Chloramphenicol' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Chloramphenicol`,
            MAX(CASE WHEN d.name = 'Ciprofloxacin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ciprofloxacin`,
            MAX(CASE WHEN d.name = 'Azithromycin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Azithromycin`,
            MAX(CASE WHEN d.name = 'Trimethoprim/Sulfamethoxazole' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Trimethoprim/Sulfamethoxazole`,
            MAX(CASE WHEN d.name = 'Clindamycin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Clindamycin`,
            MAX(CASE WHEN d.name = 'Erythromycin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Erythromycin`,
            MAX(CASE WHEN d.name = 'Gentamicin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Gentamicin`,
            MAX(CASE WHEN d.name = 'Penicillin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Penicillin`,
            MAX(CASE WHEN d.name = 'Oxacillin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Oxacillin`,
            MAX(CASE WHEN d.name = 'Tetracycline' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Tetracycline`,
            MAX(CASE WHEN d.name = 'Ceftazidime' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ceftazidime`,
            MAX(CASE WHEN d.name = 'Tigecycline' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Tigecycline`,
            MAX(CASE WHEN d.name = 'Piperacillin/Tazobactam' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Piperacillin/Tazobactam`,
            MAX(CASE WHEN d.name = 'Ceftriaxon' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ceftriaxon`,
            MAX(CASE WHEN d.name = 'Cefotaxim' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Cefotaxim`,
            MAX(CASE WHEN d.name = 'Vancomycin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Vancomycin`,
            MAX(CASE WHEN d.name = 'Cefoxitin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Cefoxitin`,
            MAX(CASE WHEN d.name = 'Nitrofurantoin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Nitrofurantoin`,
            MAX(CASE WHEN d.name = 'Naladixic Acid' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Naladixic Acid`,
            MAX(CASE WHEN d.name = 'Amikacin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Amikacin`,
            MAX(CASE WHEN d.name = 'Amoxicillin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Amoxicillin`,
            MAX(CASE WHEN d.name = 'Cefuroxime' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Cefuroxime`,
            MAX(CASE WHEN d.name = 'Ampicillin/Sulbactam' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Ampicillin/Sulbactam`,
            MAX(CASE WHEN d.name = 'Meropenam' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Meropenam`,
            MAX(CASE WHEN d.name = 'Tobramycin' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Tobramycin`,
            MAX(CASE WHEN d.name = 'Linezolid' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Linezolid`,
            MAX(CASE WHEN d.name = 'Fuscidic acid' THEN JSON_OBJECT('zone', ds.zone, 'interpretation', ds.interpretation) ELSE '' END) AS `Fuscidic acid`
        FROM tests t
          INNER JOIN test_types tt ON tt.id = t.test_type_id
          INNER JOIN departments dt ON dt.id = tt.department_id
          INNER JOIN specimen s ON s.id = t.specimen_id
          INNER JOIN orders o ON o.id = t.order_id
          INNER JOIN encounters e ON e.id = o.encounter_id
          INNER JOIN encounter_types et ON et.id = e.encounter_type_id
          INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
          INNER JOIN clients c ON c.id = e.client_id
          INNER JOIN people p ON p.id = c.person_id
          INNER JOIN test_results tr ON tr.test_id = t.id
          LEFT JOIN drug_susceptibilities ds ON ds.test_id = t.id
          LEFT JOIN organisms o2 ON o2.id = ds.organism_id
          LEFT JOIN drugs d ON d.id = ds.drug_id
          LEFT JOIN test_statuses ts ON ts.test_id = t.id
        WHERE t.created_date BETWEEN '#{@start_date}' AND '#{@end_date}'
            AND tt.name IN ('Gram Stain', 'Culture & Sensitivity')
        GROUP BY t.id, ds.organism_id, p.first_name, p.last_name, p.sex, p.date_of_birth,
                  fs.name, o.accession_number, s.name, o.requested_by, ward_type, department ORDER BY date_registered
      ").as_json
    end

    def process_data
      {
        start_date: @start_date,
        end_date: @end_date,
        data: @data
      }
    end

    def generate_csv
      CSV.generate(headers: true) do |csv|
        csv << @data.first.as_json.keys
        @data.each do |row|
          csv << row.values
        end
      end
    end

    def save_csv_to_file
      file_path = Rails.root.join('public', 'whonet_reports', "whonet_report_#{@start_date}_to_#{@end_date}.csv")
      FileUtils.mkdir_p(File.dirname(file_path))
      csv_data = generate_csv
      File.write(file_path, csv_data)
      file_path
    end
  end
end
