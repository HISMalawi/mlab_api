# frozen_string_literal: true

# Module defines methods for Serology generating reports
module Reports
  # Generates Serology reports
  module Moh
    # Serology reports
    class Serology
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
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
        counts.each do |count|
          month_name = count.month.downcase
          REPORT_INDICATORS.each do |_indicator|
            @report[month_name][count.indicator.to_sym] = {
              count: count.total,
              associated_ids: UtilsService.insert_drilldown({ associated_ids: count.associated_ids }, 'Serology')
            }
          end
        end
        @report
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
              t.test_type_id IN #{report_utils.test_type_ids('Syphilis Test')}
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
              t.test_type_id IN #{report_utils.test_type_ids('Syphilis Test')}
                  AND ti.id IN #{report_utils.test_indicator_ids(%w[RPR VDRL TPHA])}
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
              t.test_type_id IN #{report_utils.test_type_ids('Syphilis Test')}
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
              t.test_type_id IN #{report_utils.test_type_ids('Syphilis Test')}
                AND ti.id IN #{report_utils.test_indicator_ids(%w[RPR VDRL TPHA])}
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
            t.test_type_id IN #{report_utils.test_type_ids('Hepatitis')}
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
            t.test_type_id IN #{report_utils.test_type_ids('Hepatitis')}
              AND ti.id IN #{report_utils.test_indicator_ids(['Hepatitis B'])}
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
            t.test_type_id IN #{report_utils.test_type_ids('Hepatitis C Test')}
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
            t.test_type_id IN #{report_utils.test_type_ids('Hepatitis C')}
              AND ti.id IN #{report_utils.test_indicator_ids('Hepatitis C')}
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
              t.test_type_id IN #{report_utils.test_type_ids('Pregnancy Test')}
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
            t.test_type_id IN #{report_utils.test_type_ids('Pregnancy Test')}
              AND ti.id IN #{report_utils.test_indicator_ids('Pregnancy Test')}
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
            t.test_type_id IN #{report_utils.test_type_ids('HIV')}
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
            t.test_type_id IN #{report_utils.test_type_ids('HIV')}
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
              t.test_type_id IN #{report_utils.test_type_ids('Prostate Ag Test')}
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
            t.test_type_id IN #{report_utils.test_type_ids('Prostate Ag Test')}
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
              t.test_type_id IN #{report_utils.test_type_ids('SARS COV-2 Rapid Antigen')}
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
            t.test_type_id IN #{report_utils.test_type_ids('SARS COV-2 Rapid Antigen')}
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
            (t.test_type_id IN #{report_utils.test_type_ids('Serum CrAg')} OR t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')})
            AND (t.specimen_id IN #{report_utils.specimen_ids('Blood')} OR t.specimen_id IN #{report_utils.specimen_ids('Serum')})
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
            (t.test_type_id IN #{report_utils.test_type_ids('Serum CrAg')} OR t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')})
            AND (t.specimen_id IN #{report_utils.specimen_ids('Blood')} OR t.specimen_id IN #{report_utils.specimen_ids('Serum')})
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
