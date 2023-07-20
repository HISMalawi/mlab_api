module Reports
  module Aggregate
    class Infection
      def generate_report(from: nil, to: nil, department: nil)
        data = []
        tests = Test.includes(:test_type).where(test_types: { department_id: department.present? ? department : '' }).where('tests.created_date >= ?', from).where('tests.created_date <= ?', to)
        tests.each do |test|
          test_type = test.test_type
          next unless test_type
          test_data = {
            'test_type' => test_type.name,
            'indicators' => [],
            'genders' => [ {:name => 'male'}, {:name => 'female'}]
          }
          test.indicators.each do |indicator|
            result = indicator['result']
            sex = test.client['sex']
            age = calculate_age(test.client['date_of_birth'], test.created_date)
            indicator_data = {
              'indicator' => indicator,
              'M' => {
                '0-5' => 0,
                '5-14' => 0,
                '14-120' => 0
              },
              'F' => {
                '0-5' => 0,
                '5-14' => 0,
                '14-120' => 0
              }
            }
            increment_age_range(indicator_data, result, sex, age)
            test_data['indicators'] << indicator_data
          end
          data << test_data
        end
        data
      end

      def get_summary(department: nil)
        department = department.present? ?  " WHERE t.department_id = #{department}" : ''
        query = <<-SQL
          SELECT t.name, COUNT(*) AS test_count
          FROM tests AS ts
          JOIN test_types AS t ON ts.test_type_id = t.id
          #{department}
          GROUP BY t.name
        SQL
        ActiveRecord::Base.connection.execute(query)
      end

      private

      def calculate_age(date_of_birth, created_date)
        age = 0
        unless date_of_birth.nil?
          birth_date = Date.parse(date_of_birth)
          now = created_date
          age = now.year - birth_date.year
          if now.month < birth_date.month || (now.month == birth_date.month && now.day < birth_date.day)
            age -= 1
          end
        end
        age
      end

      def increment_age_range(indicator_data, result, sex, age)
        sex_range = indicator_data[sex]
        if age.between?(0, 5)
          sex_range['0-5'] += result.nil? ? 1 : 0
        elsif age.between?(6, 14)
          sex_range['5-14'] += result.nil? ? 1 : 0
        elsif age.between?(15, 120)
          sex_range['14-120'] += result.nil? ? 1 : 0
        end
      end
    end
  end
end
