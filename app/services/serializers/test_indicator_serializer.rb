# frozen_string_literal: true

module Serializers
  # TestIndicatorSerializer for building the JSON response for the Test Indicator
  class TestIndicatorSerializer
    def initialize(test_id, test_type_id, sex, dob)
      @test_id = test_id
      @test_type_id = test_type_id
      @sex = sex
      @dob = dob
    end

    def serialize
      test_indicators_serializer(test_indicators)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def test_indicators_serializer(test_indicators)
      response = []
      test_type = TestType.find(@test_type_id)
      fbc_format = Tests::FormatService.fbc_format
      test_indicators.each do |test_indicator|
        if test_type.name.include?('FBC')
          fbc_format[test_indicator['name'].upcase.to_sym] = test_indicator_seriliazer(test_indicator)
        else
          response << test_indicator_seriliazer(test_indicator)
        end
      end
      response = Tests::FormatService.to_array(fbc_format) if test_type.name.include?('FBC')
      response
    end
    # rubocop:enable Metrics/MethodLength

    def test_indicator_seriliazer(test_indicator)
      {
        id: test_indicator['id'],
        name: test_indicator['name'],
        test_indicator_type: test_indicator['test_indicator_type'],
        unit: test_indicator['unit'],
        description: test_indicator['description'],
        result: Serializers::TestResultSerializer.serialize(@test_id, test_indicator_id: test_indicator['id'])&.first,
        indicator_ranges: test_indicator_ranges(test_indicator)
      }
    end

    def test_indicators
      TestIndicator.find_by_sql(
        "SELECT
          ti.id, ti.name, ti.test_indicator_type, ti.unit, ti.description
        FROM test_indicators ti INNER JOIN test_type_indicator_mappings ttim
            ON ttim.test_indicators_id = ti.id AND ti.retired = 0
            AND ttim.test_types_id = #{@test_type_id} AND ttim.voided = 0"
      )
    end

    def test_indicator_ranges(test_indicator)
      sex = UtilsService.full_sex(@sex)
      age = UtilsService.age(@dob)
      ranges = TestIndicatorRange.where(test_indicator_id: test_indicator['id'])
      if test_indicator['test_indicator_type'].downcase == 'numeric'
        ranges = ranges.where(age_condition(age)).where(sex_condition(sex))
      end
      uniq_ranges = ranges.uniq { |range| [range.test_indicator_id, range.value] }
      map_indicator_ranges(uniq_ranges)
    end

    def result_seriliazer(id, value, result_date, machine_name)
      return {} if id.nil?

      { id:, value:, result_date:, machine_name: }
    end

    # rubocop:disable Metrics/MethodLength
    def map_indicator_ranges(ranges)
      ranges.map do |range|
        {
          id: range.id,
          test_indicator_id: range.test_indicator_id,
          sex: range.sex,
          min_age: range.min_age,
          max_age: range.max_age,
          lower_range: range.lower_range,
          upper_range: range.upper_range,
          interpretation: range.interpretation,
          value: range.value
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def age_condition(age)
      TestIndicatorRange.arel_table[:min_age].lteq(age).and(TestIndicatorRange.arel_table[:max_age].gteq(age))
    end

    def sex_condition(sex)
      TestIndicatorRange
        .arel_table[:sex].eq(sex)
        .or(TestIndicatorRange.arel_table[:sex].eq('both'))
    end
  end
end
