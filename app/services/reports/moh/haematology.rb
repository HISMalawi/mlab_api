module Reports
  module Moh
    class Haematology
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = []
        initialize_report_counts
        report_indicators
      end
    
      private

      def report_indicators
        @report_indicator = [
          "Full Blood Count", "Heamoglobin only (blood donors excluded)", "Heamoglobin only (Hemacue)", "Patients with Hb ≤ 6.0g/dl", "Patients with Hb ≤ 6.0g/dl who were transfused", "Patients with Hb > 6.0 g/dl",
          "Patients with Hb > 6.0 g/dl who were transfused", "WBC manual count", "Manual WBC differential", "Erythrocyte Sedimentation Rate (ESR)", "Sickling Test", "Reticulocyte count", "Prothrombin time (PT)",
          "Activated Partial Thromboplastin Time (APTT)", "International Normalized Ratio (INR)", "Bleeding/ cloting time", "CD4 absolute count", "CD4 percentage", "Blood film for red cell morphology"
        ]
      end
      
      def initialize_report_counts
        (1..12).each do |month_number|
          month_name = Date::MONTHNAMES[month_number].downcase
          @report[month_name] = {}
          report_indicators.each do |indicator|
            @report[month_name][indicator.to_sym] = 0
          end
        end
      end

      def update_report_counts(counts)
        counts.each do |count|
          month_name = Date::MONTHNAMES[count.month.to_i].downcase
          @report[month_name] = {}
          report_indicators.each do |indicator|
            @report[month_name][indicator.to_sym] = count.send(indicator.parameterize.underscore)
          end
        end
      end
  
      public

      def generate_report
        department = "Haematology"
        counts = MohReport.select(<<-SQL
          month,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') THEN test_id END) AS full_blood_count,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') AND test_indicator_name = 'HGB' THEN test_id END) AS heamoglobin_only_blood_donors_excluded,
          COUNT(DISTINCT CASE WHEN test_type IN ('Hemoglobin', 'Heamoglobin','Haemoglobin') 
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') THEN test_id END) AS heamoglobin_only_hemacue,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin') 
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 THEN test_id END) AS patients_with_hb_6_0g_dl,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin') 
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 THEN 
            (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' THEN test_id END)
            END) AS patients_with_hb_6_0g_dl_who_were_transfused,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin') 
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result > 6 THEN test_id END) AS patients_with_hb_6_0_g_dl,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin') 
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result > 6 THEN 
            (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' THEN test_id END)
            END) AS patients_with_hb_6_0_g_dl_who_were_transfused,
          COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' THEN test_id END) AS wbc_manual_count, 
          COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' THEN test_id END) AS manual_wbc_differential,
          COUNT(DISTINCT CASE WHEN test_type IN ('ESR','ESR Peads') THEN test_id END) AS erythrocyte_sedimentation_rate_esr,
          COUNT(DISTINCT CASE WHEN test_type = 'Sickling Test' THEN test_id END) AS sickling_test,
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC(Paeds)') AND test_indicator_name = 'RET#' THEN test_id END) AS reticulocyte_count,
          COUNT(DISTINCT CASE WHEN test_type = 'Prothrombin Time' THEN test_id END) AS prothrombin_time_pt,
          COUNT(DISTINCT CASE WHEN test_type = 'APTT' THEN test_id END) AS activated_partial_thromboplastin_time_aptt,
          COUNT(DISTINCT CASE WHEN test_type = 'INR' THEN test_id END) AS international_normalized_ratio_inr,
          COUNT(DISTINCT CASE WHEN test_type = 'Bleeding Time'  THEN test_id END) AS bleeding_cloting_time,
          COUNT(DISTINCT CASE WHEN test_type = 'CD4' AND test_indicator_name = 'CD4 Count' THEN test_id END) AS cd4_absolute_count,
          COUNT(DISTINCT CASE WHEN test_type = 'CD4' AND test_indicator_name = 'CD4 %' THEN test_id END) AS cd4_percentage,
          COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' THEN test_id END) AS blood_film_for_red_cell_morphology
        SQL
        )
        .where(department: department, year: @year)
        .group(:month)
      
        update_report_counts(counts)
      end

    end
  end
end