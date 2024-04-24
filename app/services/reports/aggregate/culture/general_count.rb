module Reports
  module Aggregate
    module Culture
      class GeneralCount
        def generate_report(month: nil, year: nil)
          process_data(query_record(month:, year:))
        end

        def process_data(records)
          data = expect_outcome
          records.each do |record|
            data["#{record[:result]}".to_sym] = record[:total]
          end
          data
        end

        def query_record(month: nil, year: nil)
          department = Department.find_by(name: 'Microbiology').id
          Report.find_by_sql(
            "SELECT
              tr.value AS result,
              count(DISTINCT t.id) AS total
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
                  where tt.id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                  AND t.status_id IN (4,5)
                  AND tr.value NOT IN ('0', '')
                  AND YEAR(t.created_date) =  #{year} AND month(t.created_date) = #{month}
                  GROUP BY result
          "
          )
        end

        def expect_outcome
          { "Growth": 0, "No growth": 0, "Mixed growth; no predominant organism": 0,
            "Growth of normal flora; no pathogens isolated": 0, "Growth of contaminants": 0 }
        end

        def report_utils
          Reports::Moh::ReportUtils
        end
      end
    end
  end
end
