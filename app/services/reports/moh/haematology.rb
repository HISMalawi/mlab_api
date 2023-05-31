module Reports
  module Moh
    module Haematology
      class  << self

        def generate_report(year, department)
          counts = MohReport.select(
            "month",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') THEN test_id END) AS fbc",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') AND test_indicator_name = 'HGB' THEN test_id END) AS hgb_o_bd_excluded",
            "COUNT(DISTINCT CASE WHEN test_type IN ('Hemoglobin', 'Heamoglobin','Haemoglobin') 
              AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') THEN test_id END) AS hgb_only_Hemacue",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin') 
              AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 THEN test_id END) AS patient_with_hb_less_or_equal_6",
          ).where(
            department: department, 
            year: year
          ).group(:month)
          serialize_report(counts)
        end

        def serialize_report(counts)
          report = {}
          counts.each do |count|
          report[count.month] = {
            full_blood_count: count.fbc,
              hgb_only_blod_donor_excluded: count.hgb_o_bd_excluded
            }
          end
          report 
        end

      end
    end
  end
end