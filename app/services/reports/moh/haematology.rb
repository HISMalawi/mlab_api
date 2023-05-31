module Reports
  module Moh
    module Haematology
      class  << self

        def generate_report(year)
          department = "Haematology"
          counts = MohReport.select(
            "month",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') THEN test_id END) AS fbc",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') AND test_indicator_name = 'HGB' THEN test_id END) AS hgb_o_bd_excluded",
            "COUNT(DISTINCT CASE WHEN test_type IN ('Hemoglobin', 'Heamoglobin','Haemoglobin') 
              AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') THEN test_id END) AS hgb_only_hemacue",
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
            report[Date::MONTHNAMES[count.month.to_i].downcase] = {
              "Full Blood Count": count.fbc,
              "Heamoglobin only (blood donors excluded)": count.hgb_o_bd_excluded,
              "Heamoglobin only (Hemacue)": count.hgb_only_hemacue,
              "Patients with Hb ≤ 6.0g/dl": count.patient_with_hb_less_or_equal_6
            }
          end
          report 
        end

      end
    end
  end
end