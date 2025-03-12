module WhonetService
  class WhoNet
    def initialize(start_date, end_date)
      @start_date = start_date.to_date.beginning_of_day
      @end_date = end_date.to_date.end_of_day
      @data = Report.find_by_sql("
          SELECT
            p.first_name, p.last_name, p.sex AS gender, p.date_of_birth AS dob,
            fs.name AS ward_or_location, o.accession_number, s.name AS specimen_type,
            o.requested_by, t.id AS test_id, ds.organism_id,
            CASE
              WHEN tr.value = '0' OR tr.value IS NULL THEN NULL
              WHEN UPPER(tr.value) = 'GROWTH' AND o2.id IS NOT NULL THEN o2.name
              ELSE tr.value
            END AS organism,
            MAX(CASE WHEN d.name = 'Amoxicillin/Clavulanate' THEN ds.zone ELSE '' END) AS `Amoxicillin/Clavulanate`,
            MAX(CASE WHEN d.name = 'Ampicillin' THEN ds.zone ELSE '' END) AS `Ampicillin`,
            MAX(CASE WHEN d.name = 'Ceftriaxone' THEN ds.zone ELSE '' END) AS `Ceftriaxone`,
            MAX(CASE WHEN d.name = 'Chloramphenicol' THEN ds.zone ELSE '' END) AS `Chloramphenicol`,
            MAX(CASE WHEN d.name = 'Ciprofloxacin' THEN ds.zone ELSE '' END) AS `Ciprofloxacin`,
            MAX(CASE WHEN d.name = 'Azithromycin' THEN ds.zone ELSE '' END) AS `Azithromycin`,
            MAX(CASE WHEN d.name = 'Trimethoprim/Sulfamethoxazole' THEN ds.zone ELSE '' END) AS `Trimethoprim/Sulfamethoxazole`,
            MAX(CASE WHEN d.name = 'Clindamycin' THEN ds.zone ELSE '' END) AS `Clindamycin`,
            MAX(CASE WHEN d.name = 'Erythromycin' THEN ds.zone ELSE '' END) AS `Erythromycin`,
            MAX(CASE WHEN d.name = 'Gentamicin' THEN ds.zone ELSE '' END) AS `Gentamicin`,
            MAX(CASE WHEN d.name = 'Penicillin' THEN ds.zone ELSE '' END) AS `Penicillin`,
            MAX(CASE WHEN d.name = 'Oxacillin' THEN ds.zone ELSE '' END) AS `Oxacillin`,
            MAX(CASE WHEN d.name = 'Tetracycline' THEN ds.zone ELSE '' END) AS `Tetracycline`,
            MAX(CASE WHEN d.name = 'Ceftazidime' THEN ds.zone ELSE '' END) AS `Ceftazidime`,
            MAX(CASE WHEN d.name = 'Tigecycline' THEN ds.zone ELSE '' END) AS `Tigecycline`,
            MAX(CASE WHEN d.name = 'Piperacillin/Tazobactam' THEN ds.zone ELSE '' END) AS `Piperacillin/Tazobactam`,
            MAX(CASE WHEN d.name = 'Ceftriaxon' THEN ds.zone ELSE '' END) AS `Ceftriaxon`,
            MAX(CASE WHEN d.name = 'Cefotaxim' THEN ds.zone ELSE '' END) AS `Cefotaxim`,
            MAX(CASE WHEN d.name = 'Vancomycin' THEN ds.zone ELSE '' END) AS `Vancomycin`,
            MAX(CASE WHEN d.name = 'Cefoxitin' THEN ds.zone ELSE '' END) AS `Cefoxitin`,
            MAX(CASE WHEN d.name = 'Nitrofurantoin' THEN ds.zone ELSE '' END) AS `Nitrofurantoin`,
            MAX(CASE WHEN d.name = 'Naladixic Acid' THEN ds.zone ELSE '' END) AS `Naladixic Acid`,
            MAX(CASE WHEN d.name = 'Amikacin' THEN ds.zone ELSE '' END) AS `Amikacin`,
            MAX(CASE WHEN d.name = 'Amoxicillin' THEN ds.zone ELSE '' END) AS `Amoxicillin`,
            MAX(CASE WHEN d.name = 'Cefuroxime' THEN ds.zone ELSE '' END) AS `Cefuroxime`,
            MAX(CASE WHEN d.name = 'Ampicillin/Sulbactam' THEN ds.zone ELSE '' END) AS `Ampicillin/Sulbactam`,
            MAX(CASE WHEN d.name = 'Meropenam' THEN ds.zone ELSE '' END) AS `Meropenam`,
            MAX(CASE WHEN d.name = 'Tobramycin' THEN ds.zone ELSE '' END) AS `Tobramycin`,
            MAX(CASE WHEN d.name = 'Linezolid' THEN ds.zone ELSE '' END) AS `Linezolid`,
            MAX(CASE WHEN d.name = 'Fuscidic acid' THEN ds.zone ELSE '' END) AS `Fuscidic acid`
        FROM tests t
          INNER JOIN test_types tt ON tt.id = t.test_type_id
          INNER JOIN specimen s ON s.id = t.specimen_id
          INNER JOIN orders o ON o.id = t.order_id
          INNER JOIN encounters e ON e.id = o.encounter_id
          INNER JOIN facility_sections fs ON fs.id = e.facility_section_id
          INNER JOIN clients c ON c.id = e.client_id
          INNER JOIN people p ON p.id = c.person_id
          INNER JOIN test_results tr ON tr.test_id = t.id
          LEFT JOIN drug_susceptibilities ds ON ds.test_id = t.id
          LEFT JOIN organisms o2 ON o2.id = ds.organism_id
          LEFT JOIN drugs d ON d.id = ds.drug_id
        WHERE t.created_date BETWEEN '#{@start_date}' AND '#{@end_date}'
            AND tt.name IN ('Gram Stain', 'Culture & Sensitivity')
        GROUP BY t.id, ds.organism_id, p.first_name, p.last_name, p.sex, p.date_of_birth,
                  fs.name, o.accession_number, s.name, o.requested_by, organism
      ")
    end

    def process_data
      {
        start_date: @start_date,
        end_date: @end_date,
        data: @data
      }
    end
  end
end
