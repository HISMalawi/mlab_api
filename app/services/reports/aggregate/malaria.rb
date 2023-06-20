# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # Malaria reports module
    module Malaria
      class << self
        def query_data_by_ward(from: nil, to: nil)
          ReportRawData.find_by_sql(
            "SELECT
            ward,
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
          "
          )
        end

        def query_data_by_gender(from: nil, to: nil)
          ReportRawData.find_by_sql(
            "SELECT
            gender,
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
          "
          )
        end

        def process_data_by_ward(record_data)
          summary = {
            total_tested: {
              micro_over_5: 0,
              micro_under_5: 0,
              mrdt_over_5: 0,
              mrdt_under_5: 0
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
          end
          summary
        end
      end
    end
  end
end


# today = Date.today.strftime('%Y-%m-%d')
#           from = from.present? ? from : today
#           to = to.present? ? to : today