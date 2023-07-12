# frozen_string_literal: true

# Module Reports
module Reports
  # Daily reports module
  module DailyReport
    # Module service for generating daily log reports
    module DailyLog
      class << self
        def generate_report(report_type, options = {})
          case report_type
          when 'test_record'
            test_record(options[:from], options[:to], options[:test_status], options[:department], options[:test_type])
          when 'patient_record'
            patient_record(options[:from], options[:to])
          else
            []
          end
        end

        def test_record(from, to, test_status, department, test_type)
          from = from.present? ? from : Date.today
          to = to.present? ? to : Date.today
          test_status = (test_status.present?) ? "'#{test_status}'" : "'completed', 'verified'"
          test_status_condition = test_status.downcase == "'all'" ? ' ' : "AND rrd.status_name IN (#{test_status})"
          depart_condition = department.present? ? " AND rrd.department = '#{department}' " : ' '
          test_type_condition = test_type.present? ? " AND rrd.test_type = '#{test_type}' " : ' '
          collection = ReportRawData.find_by_sql("
            SELECT * FROM report_raw_data rrd INNER JOIN (
              SELECT test_id, MAX(status_created_date) status_created_date FROM report_raw_data
                GROUP BY test_id
            ) mrrd ON mrrd.test_id = rrd.test_id AND rrd.status_created_date=mrrd.status_created_date
            AND rrd.created_date BETWEEN '#{from}' AND '#{to}' #{depart_condition} #{test_type_condition}
            #{test_status_condition}
          ")
          {
            from:,
            to:,
            test_status: test_status.gsub(/'/, '').split(', '),
            department:,
            test_type: test_type,
            data: serialize_test_record(collection)
          }
        end

        def patient_record(from, to)
          from = from.present? ? from : Date.today.strftime("%Y-%m-%d")
          to = to.present? ? to : Date.today.strftime("%Y-%m-%d")
          collection = ReportRawData.find_by_sql("
            SELECT DISTINCT(rrd.test_id) test_id, rrd.patient_no, rrd.patient_name, rrd.accession_number, rrd.specimen,
            rrd.test_type, rrd.dob, rrd.gender
             FROM report_raw_data rrd INNER JOIN (
              SELECT test_id, MAX(status_created_date) status_created_date FROM report_raw_data
                GROUP BY test_id, accession_number, test_type, specimen
            ) mrrd ON mrrd.test_id = rrd.test_id AND rrd.status_created_date=mrrd.status_created_date
            AND rrd.created_date BETWEEN '#{from}' AND '#{to}'
          ")
          {
            from:,
            to:,
            visits: ReportRawData.where(created_date: from..to).distinct(:encounter_id).count,
            data: serialize_patient_record(collection)
          }
        end

        def serialize_test_record(collection)
          unique_hashes = {}
          collection.each do |hash|
            test_id = hash[:test_id]
            result_date = hash[:result_date]
            test_indicator_name = hash[:test_indicator_name]
            performed_by = TestStatus.where(test_id:, status_id: 4).first
            authorized_by = TestStatus.where(test_id:, status_id: 5).first
            result = hash[:result]
            if unique_hashes[test_id].nil?
              unique_hashes[test_id] = {
                test_id:,
                patient_id: hash[:patient_no],
                visit_no: hash[:encounter_id],
                patient_name: hash[:patient_name],
                accession_number: hash[:accession_number],
                specimen: hash[:specimen],
                receipt_date: hash[:order_status_created_date],
                test: hash[:test_type],
                test_status: hash[:status_name],
                test_status_date: hash[:test_status_created_date],
                order_status: hash[:order_status_name],
                department: hash[:department],
                rejection_reason: hash[:status_rejection_reason],
                person_talked_to: hash[:status_person_talked_to],
                performed_by: performed_by.nil? ? '' : User.find(performed_by.creator).person.fullname,
                authorized_by: authorized_by.nil? ? '' : User.find(authorized_by.creator).person.fullname,
                remarks: '',
                result_date:,
                results: { test_indicator_name => result }
              }
            else
              unique_hashes[test_id][:results][test_indicator_name] = result
            end
          end
          unique_hashes.values
        end

        def serialize_patient_record(collection)
          merged_tests = []
          grouped_tests = collection.group_by { |test| test[:accession_number] }
          grouped_tests.each do |_accession_number, group|
            merged_test = group.first.clone
            test_type = group.map { |test| test[:test_type] }
            merged_tests << {
              test_id: merged_test[:test_id],
              patient_no: merged_test[:patient_no],
              patient_name: merged_test[:patient_name],
              accession_number: merged_test[:accession_number],
              specimen: merged_test[:specimen],
              test_type:,
              dob: merged_test[:dob],
              gender: merged_test[:gender]
            }
          end
          merged_tests
        end
      end
    end
  end
end
