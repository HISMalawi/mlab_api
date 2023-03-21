module TestCatalog
  module TestTypeCreateUtil
    class << self
      def perform_create_test_indicator(testtype_id, indicators)
        return_value = {status: true, error: false, message: "successful"}
        indicators.each do |indicator|
          test_indicator_status = create_test_indicator(testtype_id, indicator)
            return_value = test_indicator_status
        end
        return return_value
      end

      def create_test_indicator(testtype_id, indicator)
        test_indicator = TestIndicator.new(name: indicator[:name], test_type_id: testtype_id, test_indicator_type: indicator[:test_indicator_type], 
          unit: indicator[:unit], description: indicator[:description], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        if test_indicator.save!
          if indicator.has_key?('indicator_ranges') && indicator[:indicator_ranges].is_a?(Array)
            create_test_indicator_range(indicator[:indicator_ranges], test_indicator.id, indicator[:test_indicator_type])
            return {status: true, error: false, message: ""}
          else
            raise ActiveRecord::Rollback
          end
        end
      end
      
      def create_test_indicator_range(indicator_ranges, test_indicator_id, test_indicator_type)
        if test_indicator_type == TestCatalog::TestIndicatorType::AUTO_COMPLETE || test_indicator_type == TestCatalog::TestIndicatorType::ALPANUMERIC
          indicator_ranges.each do |indicator_range|
            create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
          end
        elsif test_indicator_type == TestCatalog::TestIndicatorType::NUMERIC
          indicator_ranges.each do |indicator_range|
            create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
          end
        end
      end

      def create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
        TestIndicatorRange.create!(test_indicator_id: test_indicator_id, value: indicator_range[:value], interpretation: indicator_range[:interpretation], retired: 0, 
          creator: User.current.id, created_date: Time.now, updated_date: Time.now)
      end

      def create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
        TestIndicatorRange.create!(test_indicator_id: test_indicator_id, min_age: indicator_range[:min_age], max_age: indicator_range[:max_age], interpretation: indicator_range[:interpretation], 
          retired: 0, sex: indicator_range[:sex], lower_range: indicator_range[:lower_range], upper_range: indicator_range[:upper_range], creator: User.current.id, created_date: Time.now, updated_date: Time.now)
      end

      def create_specimen_test_type_mapping(testtype_id, specimen_ids)
        specimen_ids.each do |specimen_id|
          SpecimenTestTypeMapping.create!(specimen_id: specimen_id, test_type_id: testtype_id, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        end
      end

    end
  end
end