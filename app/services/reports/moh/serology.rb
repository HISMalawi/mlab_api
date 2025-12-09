# frozen_string_literal: true

# Module defines methods for Serology generating reports
module Reports
  # Generates Serology reports
  module Moh
    # Serology reports
    class Serology < BaseReport
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        super
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        data = Report.where(year:, name: 'moh_serology').first&.data
        return data if data.present?

        report_data = syphilis_screening_patients + syphilis_positive_tests + syphilis_screening_antenatal_mothers +
                      syphilis_positive_tests_antenatal_mothers + hep_bs_ag_test_done_patients +
                      hep_bs_ag_positive_tests + hep_cc_ag_test_done_patients + hep_cc_ag_positive_tests +
                      hcg_pregnancy_tests_done + hcg_pregnancy_positive_tests + hiv_tests_on_pep_patients +
                      hiv_pep_positives_tests + prostate_specific_antigen_tests + psa_positive +
                      sars_covid_19_rapid_antigen_tests + sars_covid_19_positive + serum_crag + serum_crag_positive
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_serology', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        'Syphilis screening on patients',
        'Syphilis Positive tests',
        'Syphilis screening on antenatal mothers',
        'Syphilis Positive tests on antenatal mothers',
        'HepBsAg test done on patients',
        'HepBsAg Positive tests',
        'HepCcAg test done on patients',
        'HepCcAg Positive tests',
        'Hcg Pregnacy tests done',
        'Hcg Pregnacy Positive tests',
        'HIV tests on PEP patients',
        'HIV PEP positives tests',
        'Prostate Specific Antigen (PSA) tests',
        'PSA Positive',
        'SARs-COVID-19 rapid antigen tests',
        'SARs-COVID-19 Positive',
        'Serum Crag',
        'Serum Crag Positive'
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
        update_report_counts_optimized(counts, 'Serology')
      end

      def syphilis_screening_patients
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Syphilis screening on patients' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Syphilis Test'], ['NLIMS_TT_0019_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def syphilis_positive_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Syphilis Positive tests' AS indicator,
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Syphilis Test'], ['NLIMS_TT_0019_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(
                    TestIndicator,
                    ['RPR', 'VDRL', 'TPHA', 'Rapid Plasma Reagin', 'Venereal Disease Research Laboratory', 'Treponema Pallidum Haemagglutination'],
                    %w[NLIMS_TT_0251_MWI NLIMS_TT_0127_MWI NLIMS_TI_0593_MWI]
                  )}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value <> ''
                  AND tr.value = 'REACTIVE'
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def syphilis_screening_antenatal_mothers
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Syphilis screening on antenatal mothers' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
            FROM
              tests t
                  INNER JOIN
              orders o ON o.id = t.order_id AND o.voided = 0
                  INNER JOIN
              encounters e ON e.id = o.encounter_id AND e.voided = 0 AND e.facility_section_id
                  IN #{report_utils.facility_section_ids('Antenatal')}
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Syphilis Test'], ['NLIMS_TT_0019_MWI'])}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def syphilis_positive_tests_antenatal_mothers
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Syphilis Positive tests on antenatal mothers' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
            FROM
              tests t
                  INNER JOIN
              orders o ON o.id = t.order_id AND o.voided = 0
                  INNER JOIN
              encounters e ON e.id = o.encounter_id AND e.voided = 0 AND e.facility_section_id
                  IN #{report_utils.facility_section_ids('Antenatal')}
                      INNER JOIN
                  test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                      INNER  JOIN
                  test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Syphilis Test'], ['NLIMS_TT_0019_MWI'])}
                AND ti.id IN #{GlobalService.fetch_ids(
                  TestIndicator,
                  ['RPR', 'VDRL', 'TPHA', 'Rapid Plasma Reagin', 'Venereal Disease Research Laboratory', 'Treponema Pallidum Haemagglutination'],
                  %w[NLIMS_TT_0251_MWI NLIMS_TT_0127_MWI NLIMS_TI_0593_MWI]
                )}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
                AND tr.value <> ''
                AND tr.value = 'REACTIVE'
                AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hep_bs_ag_test_done_patients
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HepBsAg test done on patients' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Hepatitis B', 'Hepatitis B Test'], %w[NLIMS_TT_0020_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hep_bs_ag_positive_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HepBsAg Positive tests' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Hepatitis B', 'Hepatitis B Test'], %w[NLIMS_TT_0020_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Hepatitis B'], ['NLIMS_TI_0115_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value = 'Positive'
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hep_cc_ag_test_done_patients
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HepCcAg test done on patients' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Hepatitis C', 'Hepatitis C Test'], %w[NLIMS_TT_0021_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hep_cc_ag_positive_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HepCcAg Positive tests' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Hepatitis C', 'Hepatitis C Test'], %w[NLIMS_TT_0021_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Hepatitis C'], ['NLIMS_TI_0116_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value = 'Positive'
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hcg_pregnancy_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Hcg Pregnacy tests done' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Pregnancy Test'], ['NLIMS_TT_0044_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hcg_pregnancy_positive_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Hcg Pregnacy Positive tests' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Pregnancy Test'], ['NLIMS_TT_0044_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Pregnancy Test'], ['NLIMS_TT_0044_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value = 'Positive'
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hiv_tests_on_pep_patients
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HIV tests on PEP patients' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['HIV', 'HIV Nucleic Acid Test', 'Rapid HIV Test'], %w[NLIMS_TT_0116_MWI NLIMS_TT_0306_MWI])}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hiv_pep_positives_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'HIV PEP positives tests' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['HIV', 'HIV Nucleic Acid Test', 'Rapid HIV Test'], %w[NLIMS_TT_0116_MWI NLIMS_TT_0306_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IN ('Positive', 'Reactive')
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def prostate_specific_antigen_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Prostate Specific Antigen (PSA) tests' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Prostate Ag Test', 'Prostate-Specific Antigen'], ['NLIMS_TT_0087_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def psa_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'PSA Positive' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Prostate Ag Test', 'Prostate-Specific Antigen'], ['NLIMS_TT_0087_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value > 4
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def sars_covid_19_rapid_antigen_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'SARs-COVID-19 rapid antigen tests' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['SARS COV-2 Rapid Antigen'], ['NLIMS_TT_0102_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def sars_covid_19_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'SARs-COVID-19 Positive' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['SARS COV-2 Rapid Antigen'], ['NLIMS_TT_0102_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value = 'Positive'
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def serum_crag
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Serum Crag' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Serum CrAg', 'Cryptococcus Antigen', 'Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
            AND t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood', 'Serum'], %w[NLIMS_SP_0020_MWI NLIMS_SP_0003_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def serum_crag_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Serum Crag Positive' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Serum CrAg', 'Cryptococcus Antigen', 'Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
            AND t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood', 'Serum'], %w[NLIMS_SP_0020_MWI NLIMS_SP_0003_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value = 'Positive'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
