module Reports
  module Moh
    module Haematology
      class  << self

        def generate_report(year, department)
          counts = MohReport.select(
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') THEN test_id END) AS full_blood_count",
            "COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') AND test_indicator_name = 'HGB' THEN test_id END) AS hgb_only_blood_donor_excluded"
          ).where(
            department: department, 
            year: year
          ).first
        end

      end
    end
  end
end