module Reports
  module Aggregate
    module Culture
      class OrganismsBased
        def generate_report(month: nil, year: nil)
          process_data(query_record(month:, year:))
        end

        def query_record(month: nil, year: nil)
          department = Department.find_by(name: 'Microbiology').id
          Report.find_by_sql(
            "SELECT o.name AS organism, COUNT(DISTINCT t.id) AS total
            FROM
                tests t
                    INNER JOIN
                test_statuses ts ON ts.test_id = t.id
                    INNER JOIN
                test_indicators ti ON ti.test_type_id = t.test_type_id
                    INNER JOIN
                test_types tt ON tt.id = t.test_type_id
                    AND tt.department_id = #{department}
                    INNER JOIN
                test_results tr ON tr.test_indicator_id = ti.id
                    AND tr.test_id = t.id
                    AND tr.voided = 0
                    INNER JOIN
                drug_susceptibilities ds on ds.test_id = t.id
                    INNER JOIN
                organisms o ON o.id = ds.organism_id
                WHERE tt.id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                AND ts.status_id IN (4,5)
                AND tr.value NOT IN ('0', '')
                AND YEAR(t.created_date) =  #{year} AND month(t.created_date) = #{month}
                GROUP BY  organism"
          )
        end

        def process_data(records)
          data = []
          records.each do |record|
            data << {
              organism: record[:organism],
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
