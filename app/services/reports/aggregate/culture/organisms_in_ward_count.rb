module Reports
  module Aggregate
    module Culture
      class OrganismsInWardCount
        def generate_report(month: nil, year: nil)
          process_data(query_record(month:, year:))
        end

        def query_record(month: nil, year: nil)
          department = Department.find_by(name: 'Microbiology').id
          Report.find_by_sql("
            SELECT
                fs.name as ward , et.name as encounter, og.name AS organism, COUNT(DISTINCT t.id) AS total
            FROM
                tests t
                    INNER JOIN
                test_types tt ON tt.id = t.test_type_id AND tt.department_id = #{department}
                    INNER JOIN
                test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                    INNER  JOIN
                test_indicators ti ON ti.id = ttim.test_indicators_id
                    INNER JOIN
                test_results tr ON tr.test_indicator_id = ti.id
                    AND tr.test_id = t.id
                    AND tr.voided = 0
                    INNER JOIN
                drug_susceptibilities ds ON ds.test_id = t.id
                    INNER JOIN
                organisms og ON og.id = ds.organism_id
                    INNER JOIN
                orders o ON o.id = t.order_id
                    INNER JOIN
                encounters e ON e.id = o.encounter_id
                    INNER JOIN
                facility_sections fs ON fs.id = e.facility_section_id
                    INNER JOIN
                encounter_types et ON et.id = e.encounter_type_id
                WHERE tt.id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                  AND t.status_id IN (4,5)
                  AND tr.value NOT IN ('0', '')
                  AND YEAR(t.created_date) =  #{year} AND month(t.created_date) = #{month}
                GROUP BY organism, ward, encounter;
          ")
        end

        def process_data(records)
          data = []
          records.each do |record|
            data << {
              organism: record[:organism],
              ward: record[:ward],
              encounter: record[:encounter],
              count: record[:total]
            }
          end
          data
        end

        def report_utils
          Reports::Moh::ReportUtils
        end
      end
    end
  end
end
