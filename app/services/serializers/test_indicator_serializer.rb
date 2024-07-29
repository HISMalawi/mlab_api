# frozen_string_literal: true

module Serializers
  # TestIndicatorSerializer for building the JSON response for the Test Indicator
  class TestIndicatorSerializer
    def serialize(test_id, test_type_id, sex, dob)
      test_indicators = test_indicators(test_id, test_type_id)
      test_indicators_serializer(test_indicators, test_type_id, sex, dob)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def test_indicators_serializer(test_indicators, test_type_id, sex, dob)
      response = []
      test_type = TestType.find(test_type_id)
      fbc_format = Tests::FormatService.fbc_format
      test_indicators.each do |test_indicator|
        if test_type.name.include?('FBC')
          fbc_format[test_indicator['name'].upcase.to_sym] = test_indicator_seriliazer(test_indicator, sex, dob)
        else
          response << test_indicator_seriliazer(test_indicator, sex, dob)
        end
      end
      response = Tests::FormatService.to_array(fbc_format) if test_type.name.include?('FBC')
      response
    end
    # rubocop:enable Metrics/MethodLength

    def test_indicator_seriliazer(test_indicator, sex, dob)
      {
        id: test_indicator['id'],
        name: test_indicator['name'],
        test_indicator_type: test_indicator['test_indicator_type'],
        unit: test_indicator['unit'],
        description: test_indicator['description'],
        result: result_seriliazer(test_indicator['result_id'], test_indicator['value'], test_indicator['result_date'],
                                  test_indicator['machine_name']),
        indicator_ranges: test_indicator_ranges(test_indicator, sex, dob)
      }
    end

    def test_indicators(test_id, test_type_id)
      TestIndicator
        .find_by_sql("SELECT ti.id, ti.name, ti.test_indicator_type, ti.unit, ti.description,
                      tr.id AS result_id, tr.value, tr.result_date, tr.machine_name
                      FROM test_indicators ti INNER JOIN test_type_indicator_mappings ttim
                      ON ttim.test_indicators_id = ti.id LEFT JOIN test_results tr ON ti.id = tr.test_indicator_id
                      AND ti.retired = 0 AND tr.voided = 0 AND tr.test_id = #{test_id}
                      WHERE ttim.test_types_id = #{test_type_id}")
    end

    def test_indicator_ranges(test_indicator, sex, dob)
      sex = UtilsService.full_sex(sex)
      age = UtilsService.age(dob)
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
