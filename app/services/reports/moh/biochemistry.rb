# frozen_string_literal: true

# Module defines methods for Biochemistry generating reports
module Reports
  # Generates Biochemistry reports
  module Moh
    # Biochemistry reports
    class Biochemistry < BaseReport
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        super
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        data = Report.where(year:, name: 'moh_biochemistry').first&.data
        return data if data.present?

        report_data = glucose + liver_fuction_test + biochem_tests
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_biochemistry', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        'Blood glucose',
        'CSF glucose',
        'Total Protein',
        'Albumin',
        'Alkaline Phosphatase(ALP)',
        'Alanine aminotransferase (ALT)',
        'Amylase',
        'Antistreptolysin O (ASO)',
        'Aspartate aminotransferase(AST)',
        'Gamma Glutamyl Transferase',
        'Bilirubin Total',
        'Bilirubin Direct',
        'Calcium',
        'Chloride',
        'Cholesterol Total',
        'Cholesterol LDL',
        'Cholesterol HDL',
        'Cholinesterase',
        'C Reactive Protein (CRP)',
        'Creatinine',
        'Creatine Kinase NAC',
        'Creatine Kinase MB',
        'Haemoglobin A1c',
        'Iron',
        'Lipase',
        'Lactate Dehydrogenase (LDH)',
        'Magnesium',
        'Micro-protein',
        'Micro-albumin',
        'Phosphorus',
        'Potassium',
        'Rheumatoid Factor',
        'Sodium',
        'Triglycerides',
        'Urea',
        'Uric acid'
      ].freeze

      def initialize_report_counts
        I18n.t('date.month_names').compact.map(&:downcase).each do |month_name|
          @report[month_name] = {}
          REPORT_INDICATORS.each do |indicator|
            @report[month_name][indicator.to_sym] = {
              count: 0,
              associated_ids: ''
            }
          end
        end
      end

      def update_report_counts(counts)
        update_report_counts_optimized(counts, 'Biochemistry')
      end

      def glucose
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.specimen_id IN#{' '}
                    #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], ['NLIMS_SP_0002_MWI'])}
                  THEN 'CSF glucose'
                WHEN t.specimen_id IN#{' '}
                    #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood'], ['NLIMS_SP_0003_MWI'])}
                  THEN 'Blood glucose'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Glucose'], %w[NLIMS_TT_0038_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Glucose'], %w[NLIMS_TT_0038_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def liver_fuction_test
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Total Protein'], %w[NLIMS_TT_0079_MWI])} THEN 'Total Protein'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Albumin'], %w[NLIMS_TI_0140_MWI])} THEN 'Albumin'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['ALP', 'Alkaline Phosphatase'], %w[NLIMS_TI_0564_MWI])} THEN 'Alkaline Phosphatase(ALP)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['ALT', 'Alanine Aminotransferase/Glutamate Pyruvate Transaminase'], %w[NLIMS_TI_0133_MWI])} THEN 'Alanine aminotransferase (ALT)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['AST', 'Aspartate Aminotransferase/Glutamate Oxaloacetate Transaminase'], %w[NLIMS_TI_0134_MWI])} THEN 'Aspartate aminotransferase(AST)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GGT', 'Gamma-Glutamyl Transferase'], %w[NLIMS_TI_0136_MWI])} THEN 'Gamma Glutamyl Transferase'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Total Bilirubin', 'BIT'], %w[NLIMS_TI_0563_MWI])} THEN 'Bilirubin Total'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Direct bilirubin', 'BID'], %w[NLIMS_TI_0137_MWI])} THEN 'Bilirubin Direct'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Amylase'], %w[NLIMS_TT_0112_MWI])} THEN 'Amylase'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['ASO', 'Antistreptolysin O Titre (ASOT)'], %w[NLIMS_TI_0119_MWI])} THEN 'Antistreptolysin O (ASO)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Calcium'], %w[NLIMS_TT_0048_MWI])} THEN 'Calcium'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Chloride'], %w[NLIMS_TT_0187_MWI])} THEN 'Chloride'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Total Cholesterol', 'TC'], %w[NLIMS_TI_0565_MWI])} THEN 'Cholesterol Total'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['LDL', 'Low-Density Lipoprotein'], %w[NLIMS_TI_0238_MWI])} THEN 'Cholesterol LDL'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['HDL', 'High-Density Lipoprotein'], %w[NLIMS_TI_0237_MWI])} THEN 'Cholesterol HDL'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Potassium'], %w[NLIMS_TI_0185_MWI])} THEN 'Potassium'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Phosphorus'], %w[NLIMS_TT_0049_MWI])} THEN 'Phosphorus'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Magnesium'], %w[NLIMS_TT_0050_MWI])} THEN 'Magnesium'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Urea'], %w[NLIMS_TT_0128_MWI])} THEN 'Urea'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Uric Acid'], %w[NLIMS_TT_0052_MWI])} THEN 'Uric acid'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Triglycerides'], %w[NLIMS_TI_0145_MWI])} THEN 'Triglycerides'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Sodium'], %w[NLIMS_TI_0186_MWI])} THEN 'Sodium'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Lipase'], %w[NLIMS_TI_0230_MWI])} THEN 'Lipase'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['CRP', 'C-reactive Protein'], %w[NLIMS_TT_0025_MWI])} THEN 'C Reactive Protein (CRP)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Creatine Kinase(CKN)', 'Creatine Kinase(CKN)'], %w[NLIMS_TI_0279_MWI])} THEN 'Creatine Kinase NAC'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Creatine Kinase MB(CKMB)', 'Creatine Kinase Myoglobin Binding(CKMB)'], %w[NLIMS_TI_0278_MWI])} THEN 'Creatine Kinase MB'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Creatinine'], %w[NLIMS_TI_0021_MWI])} THEN 'Creatinine'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Lactate Dehydrogenase (LDH)', 'Lactatedehydrogenase(LDH)', 'Lactate Dehydrogenase'], %w[NLIMS_TI_0652_MWI NLIMS_TI_0280_MWI])} THEN 'Lactate Dehydrogenase (LDH)'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Iron'], %w[NLIMS_TT_0207_MWI])} THEN 'Iron'
                WHEN ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['RF', 'Rheumatoid Factor'], %w[NLIMS_TT_0022_MWI])} THEN 'Rheumatoid Factor'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(
              TestType,
              ['LFT', 'RFT', 'Pancreatic Function Test', 'Cardiac Function Tests', 'Electrolytes', 'BioMarkers', 'Rheumatoid Factor Test',
               'ASO', 'Minerals', 'Calcium', 'Chloride', 'Lipogram', 'Phosphorus', 'Potassium', 'Uric Acid', 'Sodium', 'Lipase', 'CRP',
               'Cardiac Function Tests', 'LDH', 'Iron', 'RF', 'Magnesium'],
              %w[NLIMS_TT_0032_MWI NLIMS_TT_0033_MWI NLIMS_TT_0046_MWI NLIMS_TT_0063_MWI NLIMS_TT_0036_MWI NLIMS_TT_0022_MWI NLIMS_TT_0024_MWI NLIMS_TT_0064_MWI
                 NLIMS_TT_0048_MWI NLIMS_TT_0034_MWI NLIMS_TT_0049_MWI NLIMS_TT_0052_MWI NLIMS_TT_0025_MWI NLIMS_TT_0063_MWI NLIMS_TT_0207_MWI NLIMS_TT_0066_MWI
                 NLIMS_TT_0050_MWI NLIMS_TT_0022_MWI]
            )}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def biochem_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Microprotein'], %w[NLIMS_TT_0069_MWI])} THEN 'Micro-protein'
                WHEN t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Microalbumin'], %w[NLIMS_TT_0068_MWI])} THEN 'Micro-albumin'
                WHEN t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Haemoglobin A1c', 'HbA1c'], %w[NLIMS_TT_0067_MWI])} THEN 'Haemoglobin A1c'
                WHEN t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cholinesterase'])} THEN 'Cholinesterase'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_results tr ON tr.test_id = t.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Microprotein', 'Microalbumin', 'Haemoglobin A1c', 'HbA1c', 'Cholinesterase'], %w[NLIMS_TT_0069_MWI NLIMS_TT_0068_MWI NLIMS_TT_0067_MWI NLIMS_TT_0070_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND ts.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
