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
            collection = query(options[:from], options[:to], options[:test_status], options[:department], options[:test_type])
            test_record(options[:from], options[:to], options[:test_status], options[:department], options[:test_type], collection)
          when 'patient_record'
            collection = query(options[:from], options[:to], options[:test_status], options[:department], options[:test_type])
            patient_record(options[:from], options[:to], collection)
          else
            []
          end
        end

        def query(from, to, test_status, department, test_type)
          from = from.present? ? from : Date.today
          to = to.present? ? to : Date.today
          test_status_ids = (test_status.present?) ? report_utils.status_ids(test_status) : report_utils.status_ids(['completed', 'verified'])
          test_status_condition = test_status.present? && test_status.downcase == "'all'" ? ' ' : "AND ts.status_id IN #{test_status_ids}"
          depart_condition = department.present? ? " AND d.name = '#{department}' " : ' '
          test_type_condition = test_type.present? ? " AND tt.name = '#{test_type}' " : ' '
          Report.find_by_sql("
            SELECT
                t.id AS test_id,
                c.id AS patient_no,
                tr.result_date,
                e.id AS visit_no,
                CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
                o.accession_number,
                s.name AS specimen,
                tt.name AS test_type,
                ti.name AS test_indicator_name,
                d.name AS department,
                tr.value AS result,
                ts.created_date AS test_status_created_date,
                os.created_date AS order_status_created_date,
                ts.status_id AS test_status_id,
                os.status_id AS order_status_id,
                os.person_talked_to AS status_person_talked_to,
                sr.description AS status_rejection_reason,
                p.sex AS gender,
                p.date_of_birth AS dob
            FROM
                tests t
                    JOIN
                orders o ON o.id = t.order_id
                    JOIN
                encounters e ON e.id = o.encounter_id
                    JOIN
                clients c ON c.id = e.client_id
                    JOIN
                people p ON p.id = c.person_id
                    JOIN
                specimen s ON s.id = t.specimen_id
                    JOIN
                test_types tt ON tt.id = t.test_type_id
                    JOIN
                test_indicators ti ON ti.test_type_id = tt.id
                    JOIN
                departments d ON d.id = tt.department_id
                    JOIN
                test_statuses ts ON ts.test_id = t.id
                    LEFT JOIN
                order_statuses os ON os.order_id = o.id
                    LEFT JOIN
                status_reasons sr ON os.status_reason_id = sr.id
                    LEFT JOIN
                test_results tr ON tr.test_id = t.id
                    AND tr.test_indicator_id = ti.id
                WHERE t.created_date BETWEEN '#{from.to_date.beginning_of_day}' AND '#{to.to_date.end_of_day}'
                #{test_status_condition}
                #{depart_condition}
                #{test_type_condition}
          ")
        end

        def test_record(from, to, test_status, department, test_type, collection)
          data = serialize_test_record(collection)
          {
            from:,
            to:,
            completed_tests: data.length,
            department:,
            test_type:,
            data:
          }
        end

        def patient_record(from, to, collection)
          data = serialize_patient_record(collection)
          {
            from:,
            to:,
            visits: data.uniq,
            data:
          }
        end

        def serialize_test_record(collection)
          unique_hashes = {}
          collection.each do |hash|
            test_id = hash[:test_id]
            result_date = hash[:result_date].present? ? hash[:result_date] : ''
            test_indicator_name = hash[:test_indicator_name]
            performed_by = TestStatus.where(test_id:, status_id: 4).first
            authorized_by = TestStatus.where(test_id:, status_id: 5).first
            result = hash[:result].nil? ? '' : hash[:result]
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
              test_type: test_type.uniq,
              dob: merged_test[:dob],
              gender: merged_test[:gender]
            }
          end
          merged_tests
        end

        def report_utils
          Reports::Moh::ReportUtils
        end
      end
    end
  end
end
