module Reports
  module Aggregate
    class TurnAroundTime
      def generate_report(from: nil, to: nil, unit: nil, department: nil)
        data = []
        test_types = fetch_test_types(department)

        tests = fetch_tests(from, to, department)
        test_types.each do |test_type|
          test_type_tests = tests.where(test_type_id: test_type.id)
          tat = system_tat(test_type.expected_turn_around_time.value, test_type.expected_turn_around_time.unit, unit)

          test_type_data = initialize_test_type_data(test_type.name, tat)
          diff_sum, count = calculate_differences(test_type_tests, unit)

          test_type_data['average'] = count.positive? ? (diff_sum / count).round(4) : 0
          data << test_type_data
        end

        data.select { |entry| entry['average'].positive? }
      end

      private

      def fetch_test_types(department)
        if lab_reception?(department)
          TestType.all
        else
          TestType.where(department_id: department)
        end
      end

      def fetch_tests(from, to, department)
        tests = Test.includes(:test_type)
                    .where(created_date: from..Date.parse(to).end_of_day)
                    .where.not(status_id: Status.where(name: %w[test-rejected rejected voided not-done]).ids)

        tests = tests.where(test_types: { department_id: department }) unless lab_reception?(department)
        tests
      end

      def initialize_test_type_data(name, tat)
        {
          'test_type' => name,
          'turn_around_time' => tat.round(4),
          'average' => 0
        }
      end

      def calculate_differences(test_type_tests, unit)
        diff_sum = 0
        count = 0

        test_type_tests.each do |test|
          created_date, completed_date = extract_dates(test)

          next unless created_date.present? && completed_date.present?

          diff = (Time.parse(completed_date) - Time.parse(created_date))
          diff_sum += difference(unit, diff).round(4)
          count += 1
        end

        [diff_sum, count]
      end

      def extract_dates(test)
        created_date = ''
        completed_date = ''

        test.status_trail.each do |status_trail|
          case status_trail.status.name
          when 'pending'
            created_date = status_trail.created_date.strftime('%Y-%m-%d %H:%M:%S')
          when 'verified', 'completed'
            completed_date = status_trail.created_date.strftime('%Y-%m-%d %H:%M:%S')
          end
        end

        [created_date, completed_date]
      end

      def lab_reception?(department)
        Department.find_by(name: 'Lab Reception')&.id&.to_s == department
      end

      def difference(unit, diff)
        return 0 unless diff

        case unit.downcase
        when 'hours'
          diff / 1.hour
        when 'minutes'
          diff / 1.minute
        when 'days'
          diff / 1.day
        when 'weeks'
          diff / 1.week
        else
          diff / 1.hour
        end
      end

      def system_tat(sys_tat, sys_unit, unit)
        tat = time_to_seconds(sys_tat, sys_unit)
        case unit&.downcase
        when 'hours' then tat / 1.hour
        when 'minutes' then tat / 1.minute
        when 'days' then tat / 1.day
        when 'weeks' then tat / 1.week
        else tat / 1.hour
        end
      end

      def time_to_seconds(time, unit)
        time = time&.to_f
        case unit&.downcase
        when 'minutes' then time * 60
        when 'hours' then time * 60 * 60
        when 'days' then time * 24 * 60 * 60
        when 'weeks' then time * 7 * 24 * 60 * 60
        else 24 * 60 * 60
        end
      end
    end
  end
end
