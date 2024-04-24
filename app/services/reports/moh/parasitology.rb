# frozen_string_literal: true

# Module defines methods for Parasitology generating reports
module Reports
  # Generates Parasitology reports
  module Moh
    # parasitology reports
    class Parasitology
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        report_data = total_malaria_microscopy_tests + total_malaria_microscopy_positive + malaria_microscopy_less_5yrs +
                      positive_malaria_slides_less_5yrs + malaria_microscopy_greater_5yrs + malaria_microscopy_unknown_age +
                      positive_malaria_slides_greater_5yrs + positive_malaria_slides_unknown_age + total_mrdts_done + positive_mrdts_done +
                      mrdts_less_5yrs + positive_mrdts_less_5yrs + mrdts_greater_5yrs + positive_mrdts_greater_5yrs + total_trypanosome_tests +
                      positive_trypanosome_tests + total_urine_microscopy + schistosome_haematobium_tests + other_urine_parasites + urine_chemistries_count +
                      semen_analysis_tests + blood_parasites_count + blood_parasites_seen + stool_microscopy_tests + stool_microscopy_parasites_seen
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_parasitology', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        'Total malaria microscopy tests done',
        'Total positive malaria microscopy tests done',
        'Malaria microscopy in <= 5yrs',
        'Positive malaria slides in <= 5yrs',
        'Malaria microscopy in > 5 yrs',
        'Positive malaria slides in > 5 yrs',
        'Malaria microscopy in unknown age',
        'Positive malaria slides in unknown age',
        'Total MRDTs Done',
        'MRDTs Positives',
        'MRDTs in <= 5yrs',
        'MRDT Positives in <= 5yrs',
        'MRDTs in > 5 yrs',
        'MRDT Positives in > 5 yrs',
        'Total invalid MRDTs tests',
        'Trypanosome tests',
        'Positive tests',
        'Urine microscopy total',
        'Schistosome Haematobium',
        'Other urine parasites',
        'Urine chemistry (count)',
        'Semen analysis (count)',
        'Blood Parasites (count)',
        'Blood Parasites seen',
        'Stool Microscopy (count)',
        'Stool Microscopy Parasites seen'
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

      def total_malaria_microscopy_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total malaria microscopy tests done' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
              INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_malaria_microscopy_positive
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total positive malaria microscopy tests done' AS indicator
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
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value NOT IN ( '', 'NMPS', 'Negative',  'no malaria palasite seen','No malaria parasites seen', 'No tryps seen', 'No parasite seen', '0', 'NPS', ' NMPS')
            AND tr.value NOT LIKE '%No parasi%'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def malaria_microscopy_less_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Malaria microscopy in <= 5yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
              INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
              INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) <= 5)
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_malaria_slides_less_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Positive malaria slides in <= 5yrs' AS indicator
            FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
              INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) <= 5)
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value NOT IN ( '', 'NMPS', 'Negative', 'no malaria palasite seen','No malaria parasites seen', 'No tryps seen', 'No parasite seen', '0', 'NPS', ' NMPS')
						AND tr.value NOT LIKE '%No parasi%'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def malaria_microscopy_greater_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Malaria microscopy in > 5 yrs' AS indicator
          FROM
            tests t
                INNER JOIN
            orders o ON o.id = t.order_id
                INNER JOIN
            encounters e ON e.id = o.encounter_id
                INNER JOIN
            clients c ON c.id = e.client_id
                INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
                INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) > 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_malaria_slides_greater_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Positive malaria slides in > 5 yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) > 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value NOT IN ( '', 'NMPS', 'Negative', 'no malaria palasite seen','No malaria parasites seen', 'No tryps seen', 'No parasite seen', '0', 'NPS', ' NMPS')
						AND tr.value NOT LIKE '%No parasi%'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def malaria_microscopy_unknown_age
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Malaria microscopy in unknown age' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND p.date_of_birth IS NULL
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_malaria_slides_unknown_age
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Positive malaria slides in unknown age' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND p.date_of_birth IS NULL
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value NOT IN ( '', 'NMPS', 'Negative', 'no malaria palasite seen','No malaria parasites seen', 'No tryps seen', 'No parasite seen', '0', 'NPS', ' NMPS')
						AND tr.value NOT LIKE '%No parasi%'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_mrdts_done
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total MRDTs Done' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
               INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_mrdts_done
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MRDTs Positives' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
						AND tr.value = 'Positive'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mrdts_less_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MRDTs in <= 5yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) <= 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_mrdts_less_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MRDT Positives in <= 5yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) <= 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value = 'Positive'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mrdts_greater_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MRDTs in > 5 yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) > 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_mrdts_greater_5yrs
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MRDT Positives in > 5 yrs' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
            AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND (TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) > 5)
            AND t.voided = 0
            AND tr.value NOT  IN ('', '0')
            AND tr.value = 'Positive'
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_trypanosome_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Trypanosome tests' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
              INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Trypanosome')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_trypanosome_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Trypanosome tests' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Trypanosome')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IN ('Positive', 'Seen')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_urine_microscopy
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Urine microscopy total' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids(['Urine Microscopy', 'Urine Microscopy (Paeds)'])}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def schistosome_haematobium_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Schistosome Haematobium' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids(['Schistosome Haematobiums', 'Schistosome Haematobium'])}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def other_urine_parasites
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Other urine parasites' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Other urine parasites')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def urine_chemistries_count
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Urine chemistry (count)' AS indicator
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
            t.test_type_id IN #{report_utils.test_type_ids('Urine Chemistry')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def semen_analysis_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Semen analysis (count)' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Semen Analysis')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def blood_parasites_count
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Blood Parasites (count)' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
               INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Blood Parasites Screen')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def blood_parasites_seen
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Blood Parasites seen' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids('Blood Parasites Screen')}
            AND YEAR(t.created_date) = #{year}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value NOT LIKE '%no%'
						AND tr.value NOT IN ('NMPS', 'NPS', '')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def stool_microscopy_tests
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Stool Microscopy (count)' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids(['Stool Analysis', 'Stool Analysis (Paeds)'])}
            AND YEAR(t.created_date) = #{year}
            AND ti.id IN #{report_utils.test_indicator_ids('Microscopy')}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def stool_microscopy_parasites_seen
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Stool Microscopy Parasites seen' AS indicator
          FROM
            tests t
              INNER JOIN
            orders o ON o.id = t.order_id
              INNER JOIN
            encounters e ON e.id = o.encounter_id
              INNER JOIN
            clients c ON c.id = e.client_id
              INNER JOIN
            people p ON p.id = c.person_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
              INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
              AND tr.test_id = t.id
              AND tr.voided = 0
          WHERE
            t.test_type_id IN #{report_utils.test_type_ids(['Stool Analysis', 'Stool Analysis (Paeds)'])}
            AND YEAR(t.created_date) = #{year}
            AND ti.id IN #{report_utils.test_indicator_ids('Microscopy')}
            AND t.status_id IN (4 , 5)
            AND t.voided = 0
            AND tr.value NOT IN ('', '0')
            AND tr.value NOT IN ('', '0', 'NPS','NMPS')
            AND tr.value IS NOT NULL
            AND NOT EXISTS (SELECT 1
              FROM (
                SELECT 'No ova' AS result UNION
                SELECT 'No Para' UNION
                SELECT 'No  Para' UNION
                SELECT 'Not Seen' UNION
                SELECT 'No cyst' UNION
                SELECT 'NO Orga' UNION
                SELECT 'Nothing' UNION
                SELECT 'No tro' UNION
                SELECT 'No cells' UNION
                SELECT 'No pala') exclude_results
              WHERE tr.value LIKE CONCAT('%', exclude_results.result, '%')
              )
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end

    end
  end
end
