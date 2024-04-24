# frozen_string_literal: true

# Module defines methods for Biochemistry generating reports
module Reports
  # Generates Biochemistry reports
  module Moh
    # Biochemistry reports
    class Biochemistry
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
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
            @report[month_name][indicator.to_sym] = 0
          end
        end
      end

      def update_report_counts(counts)
        counts.each do |count|
          month_name = count.month.downcase
          REPORT_INDICATORS.each do |_indicator|
            @report[month_name][count.indicator.to_sym] = count.total
          end
        end
        @report
      end

      def glucose
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.specimen_id IN #{report_utils.specimen_ids('CSF')} THEN 'CSF glucose'
                WHEN t.specimen_id IN #{report_utils.specimen_ids('Blood')} THEN 'Blood glucose'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total
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
            t.test_type_id IN #{report_utils.test_type_ids('Glucose')}
              AND ti.id IN #{report_utils.test_indicator_ids('Glucose')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def liver_fuction_test
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN ti.id IN #{report_utils.test_indicator_ids('Total Protein')} THEN 'Total Protein'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Albumin')} THEN 'Albumin'
                WHEN ti.id IN #{report_utils.test_indicator_ids('ALP')} THEN 'Alkaline Phosphatase(ALP)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('ALT')} THEN 'Alanine aminotransferase (ALT)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('AST')} THEN 'Aspartate aminotransferase(AST)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('GGT')} THEN 'Gamma Glutamyl Transferase'
                WHEN ti.id IN #{report_utils.test_indicator_ids('BIT')} THEN 'Bilirubin Total'
                WHEN ti.id IN #{report_utils.test_indicator_ids('BID')} THEN 'Bilirubin Direct'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Amylase')} THEN 'Amylase'
                WHEN ti.id IN #{report_utils.test_indicator_ids('ASO')} THEN 'Antistreptolysin O (ASO)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Calcium')} THEN 'Calcium'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Chloride')} THEN 'Chloride'
                WHEN ti.id IN #{report_utils.test_indicator_ids('TC')} THEN 'Cholesterol Total'
                WHEN ti.id IN #{report_utils.test_indicator_ids('LDL')} THEN 'Cholesterol LDL'
                WHEN ti.id IN #{report_utils.test_indicator_ids('HDL')} THEN 'Cholesterol HDL'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Potassium')} THEN 'Potassium'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Phosphorus')} THEN 'Phosphorus'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Magnesium')} THEN 'Magnesium'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Urea')} THEN 'Urea'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Uric Acid')} THEN 'Uric acid'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Triglycerides')} THEN 'Triglycerides'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Sodium')} THEN 'Sodium'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Lipase')} THEN 'Lipase'
                WHEN ti.id IN #{report_utils.test_indicator_ids('CRP')} THEN 'C Reactive Protein (CRP)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Creatinine')} THEN 'Creatinine'
                WHEN ti.id IN #{report_utils.test_indicator_ids('LDH')} THEN 'Lactate Dehydrogenase (LDH)'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Iron')} THEN 'Iron'
                WHEN ti.id IN #{report_utils.test_indicator_ids('RF')} THEN 'Rheumatoid Factor'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Creatine Kinase(CKN)')} THEN 'Creatine Kinase NAC'
                WHEN ti.id IN #{report_utils.test_indicator_ids('Creatine Kinase MB(CKMB)')} THEN 'Creatine Kinase MB'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total
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
            t.test_type_id IN #{report_utils.test_type_ids(['LFT', 'RFT', 'Pancreatic Function Test', 'Cardiac Function Tests',
                                                            'Electrolytes', 'BioMarkers', 'Rheumatoid Factor Test',
                                                            'ASO', 'Minerals', 'Calcium', 'Chloride', 'Lipogram', 'Phosphorus', 'Potassium',
                                                            'Uric Acid', 'Sodium', 'Lipase', 'CRP', 'Cardiac Function Tests', 'LDH', 'Iron',
                                                            'RF', 'Magnesium'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def biochem_tests
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.test_type_id IN #{report_utils.test_type_ids('Microprotein')} THEN 'Micro-protein'
                WHEN t.test_type_id IN #{report_utils.test_type_ids('Microalbumin')} THEN 'Micro-albumin'
                WHEN t.test_type_id IN #{report_utils.test_type_ids('HbA1c')} THEN 'Haemoglobin A1c'
                WHEN t.test_type_id IN #{report_utils.test_type_ids('Cholinesterase')} THEN 'Cholinesterase'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_results tr ON tr.test_id = t.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids(%w[Microprotein Microalbumin HbA1c])}
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
