# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # Malaria reports module
    module Malaria
      class << self
        def query_data_by_ward(from: nil, to: nil)
          ReportRawData.find_by_sql("
            SELECT
              ward,
              #{sql}
            FROM
                (SELECT
                    TIMESTAMPDIFF(YEAR, dob, created_date) AS age,
                        result,
                        ward,
                        test_indicator_name,
                        test_id
                FROM
                  report_raw_data
                WHERE
                    test_type IN ('Malaria Screening' , 'Malaria Screening (Paeds)', 'Malaria Blood Film', 'MRDT ..', 'MRDT')
                        AND status_id IN (4 , 5) AND created_date BETWEEN '#{from}' AND '#{to}'
                GROUP BY dob , created_date , result , ward , test_indicator_name, test_id) AS t
            GROUP BY ward
          ")
        end

        def query_data_by_female_preg(from: nil, to: nil)
          ReportRawData.find_by_sql("
            SELECT
              'Female Pregant' AS indicator,
              #{sql}
            FROM
                (SELECT
                    TIMESTAMPDIFF(YEAR, dob, created_date) AS age,
                        result,
                        ward,
                        test_indicator_name,
                        test_id
                FROM
                  report_raw_data
                WHERE
                    test_type IN ('Malaria Screening' , 'Malaria Screening (Paeds)', 'Malaria Blood Film', 'MRDT ..', 'MRDT')
                        AND status_id IN (4 , 5) AND created_date BETWEEN '#{from}' AND '#{to}' AND TIMESTAMPDIFF(YEAR, dob, created_date) > 5
                        AND ward IN ('LW', 'EM LW', 'LABOUR WARD', 'ANTENATAL', 'LABOUR') AND gender = 'F'
                GROUP BY dob , created_date , result , ward , test_indicator_name, test_id) AS t
          ")
        end

        def query_data_by_gender(from: nil, to: nil)
          ReportRawData.find_by_sql("
            SELECT
              gender,
              #{sql}
            FROM
                (SELECT
                    TIMESTAMPDIFF(YEAR, dob, created_date) AS age,
                        result,
                        gender,
                        test_indicator_name,
                        test_id
                FROM
                  report_raw_data
                WHERE
                    test_type IN ('Malaria Screening' , 'Malaria Screening (Paeds)', 'Malaria Blood Film', 'MRDT ..', 'MRDT')
                        AND status_id IN (4 , 5) AND created_date BETWEEN '#{from}' AND '#{to}'
                GROUP BY dob , created_date , result , gender , test_indicator_name, test_id) AS t
            GROUP BY gender
          ")
        end

        def query_data_by_encounter_type(from: nil, to: nil)
          ReportRawData.find_by_sql(
            "SELECT
            encounter_type,
              #{sql}
            FROM
                (SELECT
                    TIMESTAMPDIFF(YEAR, dob, created_date) AS age,
                        result,
                        encounter_type,
                        test_indicator_name,
                        test_id
                FROM
                  report_raw_data
                WHERE
                    test_type IN ('Malaria Screening' , 'Malaria Screening (Paeds)', 'Malaria Blood Film', 'MRDT ..', 'MRDT')
                        AND status_id IN (4 , 5) AND created_date BETWEEN '#{from}' AND '#{to}'
                GROUP BY dob , created_date , result , encounter_type , test_indicator_name, test_id) AS t
            GROUP BY encounter_type 
          ")
        end

        def sql
          <<-RUBY
            COUNT(DISTINCT IF(age > 5 AND result = 'negative'
            AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_neg_over5,
            COUNT(DISTINCT IF(age <= 5 AND result = 'negative'
                    AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_neg_under5,
            COUNT(DISTINCT IF(age > 5 AND result = 'invalid'
                    AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_inv_over5,
            COUNT(DISTINCT IF(age <= 5 AND result = 'invalid'
                    AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_inv_under5,
            COUNT(DISTINCT IF(age > 5
                    AND result IN ('positive' , 'postive')
                    AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_pos_over5,
            COUNT(DISTINCT IF(age <= 5
                    AND result IN ('positive' , 'postive')
                    AND test_indicator_name = 'MRDT',
                test_id,
                NULL)) AS mrdt_pos_under5,
            COUNT(DISTINCT IF(age > 5
                    AND result IN ('No parasite seen' , 'No parasite',
                    'no parasites seen',
                    'nps',
                    'NMPS',
                    'no malaria palasite seen',
                    'no malaria parasite seen')
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_neg_over5,
            COUNT(DISTINCT IF(age <= 5
                    AND result IN ('No parasite seen' , 'No parasite',
                    'no parasites seen',
                    'nps',
                    'NMPS',
                    'no malaria palasite seen',
                    'no malaria parasite seen')
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_neg_under5,
            COUNT(DISTINCT IF(age > 5
                    AND result NOT IN ('No parasite seen' , 'No parasite',
                    'no parasites seen',
                    'nps',
                    'NMPS',
                    'no malaria palasite seen',
                    'no malaria parasite seen')
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_pos_over5,
            COUNT(DISTINCT IF(age <= 5
                    AND result NOT IN ('No parasite seen' , 'No parasite',
                    'no parasites seen',
                    'nps',
                    'NMPS',
                    'no malaria palasite seen',
                    'no malaria parasite seen')
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_pos_under5,
            COUNT(DISTINCT IF(age > 5 AND result = 'invalid'
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_inv_over5,
            COUNT(DISTINCT IF(age <= 5 AND result = 'invalid'
                    AND test_indicator_name IN ('BLOOD FILM' , 'MALARIA SPECIES', 'RESULTS'),
                test_id,
                NULL)) AS micro_inv_under5
          RUBY
        end

        def process_data_by_ward(record_data)
          summary = {
            total_tested: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            },
            total_positive: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            },
            total_negative: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            }
          }
          record_data.each do |data|
            summary[:total_tested][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                     data[:micro_inv_over5]
            summary[:total_tested][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                      data[:micro_inv_under5]
            summary[:total_tested][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                    data[:mrdt_inv_over5]
            summary[:total_tested][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                     data[:mrdt_inv_under5]
            summary[:total_positive][:micro_over_5] += data[:micro_pos_over5] 
            summary[:total_positive][:micro_under_5] += data[:micro_pos_under5]
            summary[:total_positive][:mrdt_over_5] += data[:mrdt_pos_over5]
            summary[:total_positive][:mrdt_under_5] += data[:mrdt_pos_under5]
            summary[:total_negative][:micro_over_5] += data[:micro_neg_over5] 
            summary[:total_negative][:micro_under_5] += data[:micro_neg_under5]
            summary[:total_negative][:mrdt_over_5] += data[:mrdt_neg_over5]
            summary[:total_negative][:mrdt_under_5] += data[:mrdt_neg_under5]
          end
          summary
        end

        def summary_by_gender(record_data)
          summary = {
            total_male: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            },
            total_female: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0
            }
          }
          record_data.each do |data|
            if data[:gender] == 'M'
              summary[:total_male][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                      data[:micro_inv_over5]
              summary[:total_male][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                        data[:micro_inv_under5]
              summary[:total_male][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                      data[:mrdt_inv_over5]
              summary[:total_male][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                     data[:mrdt_inv_under5]
            else
              summary[:total_female][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                      data[:micro_inv_over5]
              summary[:total_female][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                        data[:micro_inv_under5]
              summary[:total_female][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                      data[:mrdt_inv_over5]
              summary[:total_female][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                      data[:mrdt_inv_under5]
            end
          end
          summary
        end

        def summary_by_female_preg(record_data)
          summary = {
            total_female_preg: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            }
          }
          record_data.each do |data|
            summary[:total_female_preg][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                    data[:micro_inv_over5]
            summary[:total_female_preg][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                      data[:micro_inv_under5]
            summary[:total_female_preg][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                    data[:mrdt_inv_over5]
            summary[:total_female_preg][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                    data[:mrdt_inv_under5]
          end
          summary
        end

        def summary_by_encounter_type(record_data)
          summary = {
            total_in_patient: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0,
            },
            total_out_patient: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0
            },
            total_referal: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0
            }
          }
          record_data.each do |data|
            if data[:encounter_type] == 'In Patient'
              summary[:total_in_patient][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                      data[:micro_inv_over5]
              summary[:total_in_patient][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                        data[:micro_inv_under5]
              summary[:total_in_patient][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                      data[:mrdt_inv_over5]
              summary[:total_in_patient][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                     data[:mrdt_inv_under5]
            elsif data[:encounter_type] == 'Out Patient'
              summary[:total_out_patient][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                      data[:micro_inv_over5]
              summary[:total_out_patient][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                        data[:micro_inv_under5]
              summary[:total_out_patient][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                      data[:mrdt_inv_over5]
              summary[:total_out_patient][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                      data[:mrdt_inv_under5]
            else
              summary[:total_referal][:micro_over_5] += data[:micro_neg_over5] + data[:micro_pos_over5] +
                                                      data[:micro_inv_over5]
              summary[:total_referal][:micro_under_5] += data[:micro_neg_under5] + data[:micro_pos_under5] +
                                                        data[:micro_inv_under5]
              summary[:total_referal][:mrdt_over_5] += data[:mrdt_neg_over5] + data[:mrdt_pos_over5] +
                                                      data[:mrdt_inv_over5]
              summary[:total_referal][:mrdt_under_5] += data[:mrdt_neg_under5] + data[:mrdt_pos_under5] +
                                                      data[:mrdt_inv_under5]
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
          {
            from:,
            to:,
            data:{
              by_ward:,
              by_gender:,
              by_encounter_type:,
              by_female_preg:            
            },
            summary:
          }
        end
      end
    end
  end
end
