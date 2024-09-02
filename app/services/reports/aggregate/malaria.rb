# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # Malaria reports module
    module Malaria
      class << self
        def query_data_by_ward(from: nil, to: nil)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          Report.find_by_sql("
          SELECT
            IF(fs.name IS NULL, 'N/A', fs.name) AS ward,
            #{sql}
          FROM
              tests t
                  INNER JOIN
              test_types tt ON tt.id = t.test_type_id
                  INNER JOIN
              orders o ON o.id = t.order_id
                  INNER JOIN
              encounters e ON e.id = o.encounter_id
                  INNER JOIN
              clients c ON c.id = e.client_id
                  INNER JOIN
              people p ON p.id = c.person_id
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
                  LEFT JOIN
              facility_sections fs ON fs.id = e.facility_section_id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
                  AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('' , '0')
                  AND tr.value IS NOT NULL
          GROUP BY ward")
        end

        def query_data_by_female_preg(from: nil, to: nil)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          Report.find_by_sql("
            SELECT
              'Female Pregant' AS indicator,
              #{sql}
            FROM
              tests t
                  INNER JOIN
              test_types tt ON tt.id = t.test_type_id
                  INNER JOIN
              orders o ON o.id = t.order_id
                  INNER JOIN
              encounters e ON e.id = o.encounter_id
                  INNER JOIN
              clients c ON c.id = e.client_id
                  INNER JOIN
              people p ON p.id = c.person_id
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
                  LEFT JOIN
              facility_sections fs ON fs.id = e.facility_section_id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
                  AND t.created_date BETWEEN '#{from.to_date.beginning_of_day}' AND '#{to.to_date.end_of_day}'
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('' , '0')
                  AND tr.value IS NOT NULL
                  AND fs.id IN #{report_utils.facility_section_ids('Maternity')}
                  AND p.sex = 'F'
                  AND TIMESTAMPDIFF(YEAR, DATE(p.date_of_birth), DATE(t.created_date)) > 10")
        end

        def query_data_by_gender(from: nil, to: nil)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          Report.find_by_sql("
            SELECT
              p.sex AS gender,
              #{sql}
            FROM
                tests t
                    INNER JOIN
                test_types tt ON tt.id = t.test_type_id
                    INNER JOIN
                orders o ON o.id = t.order_id
                    INNER JOIN
                encounters e ON e.id = o.encounter_id
                    INNER JOIN
                clients c ON c.id = e.client_id
                    INNER JOIN
                people p ON p.id = c.person_id
                    INNER JOIN
                test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                    INNER JOIN
                test_indicators ti ON ti.id = ttim.test_indicators_id
                    INNER JOIN
                test_results tr ON tr.test_indicator_id = ti.id
                    AND tr.test_id = t.id
                    AND tr.voided = 0
                    LEFT JOIN
                facility_sections fs ON fs.id = e.facility_section_id
            WHERE
                t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
                    AND t.created_date BETWEEN '#{from.to_date.beginning_of_day}' AND '#{to.to_date.end_of_day}'
                    AND t.status_id IN (4 , 5)
                    AND t.voided = 0
                    AND tr.value NOT IN ('' , '0')
                    AND tr.value IS NOT NULL
            GROUP BY gender")
        end

        def query_data_by_encounter_type(from: nil, to: nil)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          Report.find_by_sql("
            SELECT
              et.name AS encounter_type,
              #{sql}
            FROM
                tests t
                    INNER JOIN
                test_types tt ON tt.id = t.test_type_id
                    INNER JOIN
                orders o ON o.id = t.order_id
                    INNER JOIN
                encounters e ON e.id = o.encounter_id
                    INNER JOIN
                encounter_types et ON e.encounter_type_id = et.id
                    INNER JOIN
                clients c ON c.id = e.client_id
                    INNER JOIN
                people p ON p.id = c.person_id
                    INNER JOIN
                test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                    INNER JOIN
                test_indicators ti ON ti.id = ttim.test_indicators_id
                    INNER JOIN
                test_results tr ON tr.test_indicator_id = ti.id
                    AND tr.test_id = t.id
                    AND tr.voided = 0
                    LEFT JOIN
                facility_sections fs ON fs.id = e.facility_section_id
            WHERE
                t.test_type_id IN #{report_utils.test_type_ids('Malaria')}
                    AND t.created_date BETWEEN '#{from.to_date.beginning_of_day}' AND '#{to.to_date.end_of_day}'
                    AND t.status_id IN (4 , 5)
                    AND t.voided = 0
                    AND tr.value NOT IN ('' , '0')
                    AND tr.value IS NOT NULL
            GROUP BY encounter_type")
        end

        def sql
          <<-RUBY
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                DATE(p.date_of_birth),
                DATE(t.created_date)) > 5
                AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                AND tr.value NOT IN ('NMPS' , 'Negative',
                'no malaria palasite seen',
                'No malaria parasites seen',
                'No tryps seen',
                'No parasite seen',
                'NPS',
                ' NMPS')
                AND tr.value NOT LIKE '%No parasi%',
              t.id,
              NULL)) AS micro_pos_over5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                DATE(p.date_of_birth),
                DATE(t.created_date)) > 5
                AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                AND tr.value NOT IN ('NMPS' , 'Negative',
                'no malaria palasite seen',
                'No malaria parasites seen',
                'No tryps seen',
                'No parasite seen',
                'NPS',
                ' NMPS')
                AND tr.value NOT LIKE '%No parasi%',
              t.id,
              NULL)) AS micro_pos_over5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value NOT IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      AND tr.value NOT LIKE '%No parasi%',
                  t.id,
                  NULL)) AS micro_pos_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value NOT IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      AND tr.value NOT LIKE '%No parasi%',
                  t.id,
                  NULL)) AS micro_pos_under5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) > 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND (tr.value IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      OR tr.value LIKE '%No parasi%'),
                  t.id,
                  NULL)) AS micro_neg_over5,
          GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) > 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND (tr.value IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      OR tr.value LIKE '%No parasi%'),
                  t.id,
                  NULL)) AS micro_neg_over5_associated_ids,
          COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND (tr.value IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      OR tr.value LIKE '%No parasi%'),
                  t.id,
                  NULL)) AS micro_neg_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND (tr.value IN ('NMPS' , 'Negative',
                      'no malaria palasite seen',
                      'No malaria parasites seen',
                      'No tryps seen',
                      'No parasite seen',
                      'NPS',
                      ' NMPS')
                      OR tr.value LIKE '%No parasi%'),
                  t.id,
                  NULL)) AS micro_neg_under5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) > 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value = 'Invalid',
                  t.id,
                  NULL)) AS micro_inv_over5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) > 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value = 'Invalid',
                  t.id,
                  NULL)) AS micro_inv_over5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value = 'Invalid',
                  t.id,
                  NULL)) AS micro_inv_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                      DATE(p.date_of_birth),
                      DATE(t.created_date)) <= 5
                      AND ti.id IN #{report_utils.test_indicator_ids('Malaria Indicators')}
                      AND tr.value = 'Invalid',
                  t.id,
                  NULL)) AS micro_inv_under5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                  DATE(p.date_of_birth),
                  DATE(t.created_date)) > 5
                  AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                  AND tr.value IN ('Positive', 'postive'),
              t.id,
              NULL)) AS mrdt_pos_over5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                  DATE(p.date_of_birth),
                  DATE(t.created_date)) > 5
                  AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                  AND tr.value IN ('Positive', 'postive'),
              t.id,
              NULL)) AS mrdt_pos_over5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value IN ('Positive', 'postive'),
                    t.id,
                    NULL)) AS mrdt_pos_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value IN ('Positive', 'postive'),
                    t.id,
                    NULL)) AS mrdt_pos_under5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) > 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value ='Negative',
                    t.id,
                    NULL)) AS mrdt_neg_over5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) > 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value ='Negative',
                    t.id,
                    NULL)) AS mrdt_neg_over5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value ='Negative',
                    t.id,
                    NULL)) AS mrdt_neg_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value ='Negative',
                    t.id,
                    NULL)) AS mrdt_neg_under5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) > 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value = 'Invalid',
                    t.id,
                    NULL)) AS mrdt_inv_over5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) > 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value = 'Invalid',
                    t.id,
                    NULL)) AS mrdt_inv_over5_associated_ids,
            COUNT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value = 'Invalid',
                    t.id,
                    NULL)) AS mrdt_inv_under5,
            GROUP_CONCAT(DISTINCT IF(TIMESTAMPDIFF(YEAR,
                        DATE(p.date_of_birth),
                        DATE(t.created_date)) <= 5
                        AND ti.id IN #{report_utils.test_indicator_ids('MRDT')}
                        AND tr.value = 'Invalid',
                    t.id,
                    NULL)) AS mrdt_inv_under5_associated_ids
          RUBY
        end

        def process_data_by_ward(record_data)
          summary = {
            total_tested: summary_format,
            total_positive: summary_format,
            total_negative: summary_format
          }
          record_data.each do |data|
            # Micro over 5
            summary[:total_tested][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
            summary[:total_tested][:micro_over_5][:associated_ids] = [
              summary[:total_tested][:micro_over_5][:associated_ids],
              data[:micro_neg_over5_associated_ids],
              data[:micro_pos_over5_associated_ids],
              data[:micro_inv_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # Micro under 5
            summary[:total_tested][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
            summary[:total_tested][:micro_under_5][:associated_ids] = [
              summary[:total_tested][:micro_under_5][:associated_ids],
              data[:micro_neg_under5_associated_ids],
              data[:micro_pos_under5_associated_ids],
              data[:micro_inv_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # MRDT over 5
            summary[:total_tested][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
            summary[:total_tested][:mrdt_over_5][:associated_ids] = [
              summary[:total_tested][:mrdt_over_5][:associated_ids],
              data[:mrdt_neg_over5_associated_ids],
              data[:mrdt_pos_over5_associated_ids],
              data[:mrdt_inv_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # MRDT under 5
            summary[:total_tested][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
            summary[:total_tested][:mrdt_under_5][:associated_ids] = [
              summary[:total_tested][:mrdt_under_5][:associated_ids],
              data[:mrdt_neg_under5_associated_ids],
              data[:mrdt_pos_under5_associated_ids],
              data[:mrdt_inv_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # micro over 5 positive
            summary[:total_positive][:micro_over_5][:count] += data[:micro_pos_over5]
            summary[:total_positive][:micro_over_5][:associated_ids] = [
              summary[:total_positive][:micro_over_5][:associated_ids],
              data[:micro_pos_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # micro under 5 positive
            summary[:total_positive][:micro_under_5][:count] += data[:micro_pos_under5]
            summary[:total_positive][:micro_under_5][:associated_ids] = [
              summary[:total_positive][:micro_under_5][:associated_ids],
              data[:micro_pos_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # mrdt over 5 positive
            summary[:total_positive][:mrdt_over_5][:count] += data[:mrdt_pos_over5]
            summary[:total_positive][:mrdt_over_5][:associated_ids] = [
              summary[:total_positive][:mrdt_over_5][:associated_ids],
              data[:mrdt_pos_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # mrdt under 5 positive
            summary[:total_positive][:mrdt_under_5][:count] += data[:mrdt_pos_under5]
            summary[:total_positive][:mrdt_under_5][:associated_ids] = [
              summary[:total_positive][:mrdt_under_5][:associated_ids],
              data[:mrdt_pos_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            #  micro over 5 negative
            summary[:total_negative][:micro_over_5][:count] += data[:micro_neg_over5]
            summary[:total_negative][:micro_over_5][:associated_ids] = [
              summary[:total_negative][:micro_over_5][:associated_ids],
              data[:micro_neg_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # Micro under 5 negative
            summary[:total_negative][:micro_under_5][:count] += data[:micro_neg_under5]
            summary[:total_negative][:micro_under_5][:associated_ids] = [
              summary[:total_negative][:micro_under_5][:associated_ids],
              data[:micro_neg_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # mrdt over 5 neg
            summary[:total_negative][:mrdt_over_5][:count] += data[:mrdt_neg_over5]
            summary[:total_negative][:mrdt_over_5][:associated_ids] = [
              summary[:total_negative][:mrdt_over_5][:associated_ids],
              data[:mrdt_neg_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')
            # MRDT under 5 negative
            summary[:total_negative][:mrdt_under_5][:count] += data[:mrdt_neg_under5]
            summary[:total_negative][:mrdt_under_5][:associated_ids] = [
              summary[:total_negative][:mrdt_under_5][:associated_ids],
              data[:mrdt_neg_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
          end
          summary
        end

        def summary_by_gender(record_data)
          summary = {
            total_male: summary_format,
            total_female: summary_format
          }
          record_data.each do |data|
            if data[:gender] == 'M'
              # Micro over 5
              summary[:total_male][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
              summary[:total_male][:micro_over_5][:associated_ids] = [
                summary[:total_male][:micro_over_5][:associated_ids],
                data[:micro_neg_over5_associated_ids],
                data[:micro_pos_over5_associated_ids],
                data[:micro_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # Micro under 5
              summary[:total_male][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
              summary[:total_male][:micro_under_5][:associated_ids] = [
                summary[:total_male][:micro_under_5][:associated_ids],
                data[:micro_neg_under5_associated_ids],
                data[:micro_pos_under5_associated_ids],
                data[:micro_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT over 5
              summary[:total_male][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
              summary[:total_male][:mrdt_over_5][:associated_ids] = [
                summary[:total_male][:mrdt_over_5][:associated_ids],
                data[:mrdt_neg_over5_associated_ids],
                data[:mrdt_pos_over5_associated_ids],
                data[:mrdt_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT under 5
              summary[:total_male][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
              summary[:total_male][:mrdt_under_5][:associated_ids] = [
                summary[:total_male][:mrdt_under_5][:associated_ids],
                data[:mrdt_neg_under5_associated_ids],
                data[:mrdt_pos_under5_associated_ids],
                data[:mrdt_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')
            else
              # Micro over 5
              summary[:total_female][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
              summary[:total_female][:micro_over_5][:associated_ids] = [
                summary[:total_female][:micro_over_5][:associated_ids],
                data[:micro_neg_over5_associated_ids],
                data[:micro_pos_over5_associated_ids],
                data[:micro_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # Micro under 5
              summary[:total_female][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
              summary[:total_female][:micro_under_5][:associated_ids] = [
                summary[:total_female][:micro_under_5][:associated_ids],
                data[:micro_neg_under5_associated_ids],
                data[:micro_pos_under5_associated_ids],
                data[:micro_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT over 5
              summary[:total_female][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
              summary[:total_female][:mrdt_over_5][:associated_ids] = [
                summary[:total_female][:mrdt_over_5][:associated_ids],
                data[:mrdt_neg_over5_associated_ids],
                data[:mrdt_pos_over5_associated_ids],
                data[:mrdt_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT under 5
              summary[:total_female][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
              summary[:total_female][:mrdt_under_5][:associated_ids] = [
                summary[:total_female][:mrdt_under_5][:associated_ids],
                data[:mrdt_neg_under5_associated_ids],
                data[:mrdt_pos_under5_associated_ids],
                data[:mrdt_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')
            end
          end
          summary
        end

        def summary_by_female_preg(record_data)
          summary = { total_female_preg: summary_format }
          record_data.each do |data|
            # Micro over 5
            summary[:total_female_preg][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
            summary[:total_female_preg][:micro_over_5][:associated_ids] = [
              summary[:total_female_preg][:micro_over_5][:associated_ids],
              data[:micro_neg_over5_associated_ids],
              data[:micro_pos_over5_associated_ids],
              data[:micro_inv_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # Micro under 5
            summary[:total_female_preg][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
            summary[:total_female_preg][:micro_under_5][:associated_ids] = [
              summary[:total_female_preg][:micro_under_5][:associated_ids],
              data[:micro_neg_under5_associated_ids],
              data[:micro_pos_under5_associated_ids],
              data[:micro_inv_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # MRDT over 5
            summary[:total_female_preg][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
            summary[:total_female_preg][:mrdt_over_5][:associated_ids] = [
              summary[:total_female_preg][:mrdt_over_5][:associated_ids],
              data[:mrdt_neg_over5_associated_ids],
              data[:mrdt_pos_over5_associated_ids],
              data[:mrdt_inv_over5_associated_ids]
            ].compact.reject(&:empty?).join(',')

            # MRDT under 5
            summary[:total_female_preg][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
            summary[:total_female_preg][:mrdt_under_5][:associated_ids] = [
              summary[:total_female_preg][:mrdt_under_5][:associated_ids],
              data[:mrdt_neg_under5_associated_ids],
              data[:mrdt_pos_under5_associated_ids],
              data[:mrdt_inv_under5_associated_ids]
            ].compact.reject(&:empty?).join(',')
          end
          summary
        end

        def summary_format
          {
            micro_over_5: {
              count: 0,
              associated_ids: ''
            },
            micro_under_5: {
              count: 0,
              associated_ids: ''
            },
            mrdt_over_5: {
              count: 0,
              associated_ids: ''
            },
            mrdt_under_5: {
              count: 0,
              associated_ids: ''
            }
          }
        end

        def summary_by_encounter_type(record_data)
          summary = {
            total_in_patient: summary_format,
            total_out_patient: summary_format,
            total_referal: summary_format
          }
          record_data.each do |data|
            if data[:encounter_type] == 'In Patient'
              # Micro over 5
              summary[:total_in_patient][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
              summary[:total_in_patient][:micro_over_5][:associated_ids] = [
                summary[:total_in_patient][:micro_over_5][:associated_ids],
                data[:micro_neg_over5_associated_ids],
                data[:micro_pos_over5_associated_ids],
                data[:micro_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # Micro under 5
              summary[:total_in_patient][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
              summary[:total_in_patient][:micro_under_5][:associated_ids] = [
                summary[:total_in_patient][:micro_under_5][:associated_ids],
                data[:micro_neg_under5_associated_ids],
                data[:micro_pos_under5_associated_ids],
                data[:micro_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT over 5
              summary[:total_in_patient][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
              summary[:total_in_patient][:mrdt_over_5][:associated_ids] = [
                summary[:total_in_patient][:mrdt_over_5][:associated_ids],
                data[:mrdt_neg_over5_associated_ids],
                data[:mrdt_pos_over5_associated_ids],
                data[:mrdt_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT under 5
              summary[:total_in_patient][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
              summary[:total_in_patient][:mrdt_under_5][:associated_ids] = [
                summary[:total_in_patient][:mrdt_under_5][:associated_ids],
                data[:mrdt_neg_under5_associated_ids],
                data[:mrdt_pos_under5_associated_ids],
                data[:mrdt_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

            elsif data[:encounter_type] == 'Out Patient'
              # Micro over 5
              summary[:total_out_patient][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
              summary[:total_out_patient][:micro_over_5][:associated_ids] = [
                summary[:total_out_patient][:micro_over_5][:associated_ids],
                data[:micro_neg_over5_associated_ids],
                data[:micro_pos_over5_associated_ids],
                data[:micro_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # Micro under 5
              summary[:total_out_patient][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
              summary[:total_out_patient][:micro_under_5][:associated_ids] = [
                summary[:total_out_patient][:micro_under_5][:associated_ids],
                data[:micro_neg_under5_associated_ids],
                data[:micro_pos_under5_associated_ids],
                data[:micro_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT over 5
              summary[:total_out_patient][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
              summary[:total_out_patient][:mrdt_over_5][:associated_ids] = [
                summary[:total_out_patient][:mrdt_over_5][:associated_ids],
                data[:mrdt_neg_over5_associated_ids],
                data[:mrdt_pos_over5_associated_ids],
                data[:mrdt_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT under 5
              summary[:total_out_patient][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
              summary[:total_out_patient][:mrdt_under_5][:associated_ids] = [
                summary[:total_out_patient][:mrdt_under_5][:associated_ids],
                data[:mrdt_neg_under5_associated_ids],
                data[:mrdt_pos_under5_associated_ids],
                data[:mrdt_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

            else
              # Micro over 5
              summary[:total_referal][:micro_over_5][:count] += data[:micro_neg_over5] + data[:micro_pos_over5] + data[:micro_inv_over5]
              summary[:total_referal][:micro_over_5][:associated_ids] = [
                summary[:total_referal][:micro_over_5][:associated_ids],
                data[:micro_neg_over5_associated_ids],
                data[:micro_pos_over5_associated_ids],
                data[:micro_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # Micro under 5
              summary[:total_referal][:micro_under_5][:count] += data[:micro_neg_under5] + data[:micro_pos_under5] + data[:micro_inv_under5]
              summary[:total_referal][:micro_under_5][:associated_ids] = [
                summary[:total_referal][:micro_under_5][:associated_ids],
                data[:micro_neg_under5_associated_ids],
                data[:micro_pos_under5_associated_ids],
                data[:micro_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT over 5
              summary[:total_referal][:mrdt_over_5][:count] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] + data[:mrdt_inv_over5]
              summary[:total_referal][:mrdt_over_5][:associated_ids] = [
                summary[:total_referal][:mrdt_over_5][:associated_ids],
                data[:mrdt_neg_over5_associated_ids],
                data[:mrdt_pos_over5_associated_ids],
                data[:mrdt_inv_over5_associated_ids]
              ].compact.reject(&:empty?).join(',')

              # MRDT under 5
              summary[:total_referal][:mrdt_under_5][:count] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] + data[:mrdt_inv_under5]
              summary[:total_referal][:mrdt_under_5][:associated_ids] = [
                summary[:total_referal][:mrdt_under_5][:associated_ids],
                data[:mrdt_neg_under5_associated_ids],
                data[:mrdt_pos_under5_associated_ids],
                data[:mrdt_inv_under5_associated_ids]
              ].compact.reject(&:empty?).join(',')
            end
          end
          summary
        end

        def generate_report(from, to)
          by_ward = query_data_by_ward(from:, to:)
          by_gender = query_data_by_gender(from:, to:)
          by_encounter_type = query_data_by_encounter_type(from:, to:)
          by_female_preg = query_data_by_female_preg(from:, to:)
          summary_by_ward = process_data_by_ward(by_ward)
          summary_by_gender = summary_by_gender(by_gender)
          summary_by_encounter_type = summary_by_encounter_type(by_encounter_type)
          summary_by_female_preg = summary_by_female_preg(by_female_preg)
          summary = summary_by_ward.merge(summary_by_gender).merge(summary_by_encounter_type).merge(summary_by_female_preg)
          transform_summary_associated_ids(summary)
          {
            from:,
            to:,
            data: {
              by_ward: transform_data(by_ward, 'ward'),
              by_gender: transform_data(by_gender, 'gender'),
              by_encounter_type: transform_data(by_encounter_type, 'encounter_type'),
              by_female_preg: transform_data(by_female_preg, 'indicator')
            },
            summary:
          }
        end

        def report_utils
          Reports::Moh::ReportUtils
        end

        def transform_data(data, key)
          data.map do |item|
            {
              key.to_sym => item[key]
            }.merge(format(item))
          end
        end

        def transform_summary_associated_ids(data)
          data.each do |_key, value|
            value.each do |_sub_key, sub_value|
              associated_ids = sub_value[:associated_ids] || ''
              # Replace with method call
              sub_value[:associated_ids] =
                UtilsService.insert_drilldown({ associated_ids: }, 'Parasitology')
            end
          end
        end

        def format(item)
          {
            micro_pos_over5: {
              count: item['micro_pos_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_pos_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            micro_pos_under5: {
              count: item['micro_pos_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_pos_under5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            micro_neg_over5: {
              count: item['micro_neg_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_neg_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            micro_neg_under5: {
              count: item['micro_neg_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_neg_under5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            micro_inv_over5: {
              count: item['micro_inv_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_inv_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            micro_inv_under5: {
              count: item['micro_inv_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['micro_inv_under5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_pos_over5: {
              count: item['mrdt_pos_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_pos_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_pos_under5: {
              count: item['mrdt_pos_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_pos_under5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_neg_over5: {
              count: item['mrdt_neg_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_neg_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_neg_under5: {
              count: item['mrdt_neg_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_neg_under5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_inv_over5: {
              count: item['mrdt_inv_over5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_inv_over5_associated_ids'] || '' },
                'Parasitology'
              )
            },
            mrdt_inv_under5: {
              count: item['mrdt_inv_under5'] || 0,
              associated_ids: UtilsService.insert_drilldown(
                { associated_ids: item['mrdt_inv_under5_associated_ids'] || '' },
                'Parasitology'
              )
            }
          }
        end
      end
    end
  end
end
