module Reports
  module Aggregate
    class TurnAroundTime
      def generate_report(from: nil, to: nil, department: nil)
        data = {}
        test_types = TestType.where(department_id: department).limit(10)
        tests = Test.includes(:test_type).where(test_types: { department_id: department })
        test_types.each do |test_type|
          test_type_tests = tests.where(test_type_id: test_type.id).limit(20)
          test_type_data = {
            'test_type' => test_type.name,
            'turn_around_time' => test_type.expected_turn_around_time.value,
            'average' => 0
          }
          diff_sum = 0
          count = 0
          test_type_tests.each do |test|
            created_date = ''
            completed_date = ''
            test.status_trail.each do |status_trail|
              if status_trail.status.name == 'pending'
                created_date = status_trail.created_date.strftime('%Y-%m-%d %H:%M:%S')
              elsif status_trail.status.name == 'verified'
                completed_date = status_trail.created_date.strftime('%Y-%m-%d %H:%M:%S')
              end
            end
            if created_date.present? && completed_date.present?
              diff = (Time.parse(completed_date) - Time.parse(created_date)) / 1.hour
              diff_sum += diff.round
              count += 1
            end
          end
          test_type_data['average'] = diff_sum / count if count > 0
          data[test_type.name] = test_type_data
        end
        data
      end
    end
  end
end
