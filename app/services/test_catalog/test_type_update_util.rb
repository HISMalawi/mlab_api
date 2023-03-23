module TestCatalog
  module TestTypeUpdateUtil    
    class << self
      def update_test_type(testtype, params)
        testtype.update!(name: params[:name], short_name: params[:short_name], department_id: params[:department_id],
          expected_turn_around_time: params[:expected_turn_around_time], updated_date: Time.now)
      end
  
      def update_specimen_test_type_mapping(testtype_id, specimen_ids)
        specimen_record_ids = SpecimenTestTypeMapping.where(test_type_id: testtype_id, retired: 0).pluck('specimen_id')
        specimen_to_be_removed = specimen_record_ids - specimen_ids
        specimen_to_be_mapped = specimen_ids - specimen_record_ids
        if specimen_record_ids.sort == specimen_ids
          return {status: true, error: false}
        end
        if !specimen_to_be_removed.empty?
          specimen_to_be_removed.each do |specimen_id|
            specimen_test_type_mapping = SpecimenTestTypeMapping.where(specimen_id: specimen_id, test_type_id: testtype_id, retired: 0).first
            specimen_test_type_mapping.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: 'Removed from test type', updated_date: Time.now)
          end
        end
        if !specimen_to_be_mapped.empty?
          TestCatalog::TestTypeCreateUtil.create_specimen_test_type_mapping(testtype_id, specimen_to_be_mapped)
        end
      end
  
      def update_test_indicator_range(indicator_ranges, test_indicator_id, test_indicator_type)
        indicator_ranges.each do |indicator_range|
          if indicator_range.has_key?('id') && !indicator_range[:id].blank?
            test_indicator_range = TestIndicatorRange.find(indicator_range[:id])
            if test_indicator_type == TestCatalog::TestIndicatorType::AUTO_COMPLETE || test_indicator_type == TestCatalog::TestIndicatorType::ALPANUMERIC
              update_test_indicator_range_for_autocomplete(test_indicator_range, indicator_range)
            elsif test_indicator_type == TestCatalog::TestIndicatorType::NUMERIC
              update_test_indicator_range_for_numeric(test_indicator_range, indicator_range)
            end
          else
            if test_indicator_type == TestCatalog::TestIndicatorType::AUTO_COMPLETE || test_indicator_type == TestCatalog::TestIndicatorType::ALPANUMERIC
              TestCatalog::TestTypeCreateUtil.create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
            elsif test_indicator_type == TestCatalog::TestIndicatorType::NUMERIC
              TestCatalog::TestTypeCreateUtil.create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
            end
          end
        end
      end
  
      def update_test_indicator(testtype_id, indicators)
        indicator_ids = indicators.each.with_object(:id).map(&:[]).reject(&:blank?)
        indicator_record_ids = TestIndicator.where(test_type_id: testtype_id).pluck('id')
        indicators_to_be_removed = indicator_record_ids - indicator_ids
        indicators.each do |indicator|
          if indicator.has_key?('id') && !indicator[:id].blank?
            test_indicator = TestIndicator.find(indicator[:id])
            test_indicator.update(name: indicator[:name], test_indicator_type: indicator[:test_indicator_type], unit: indicator[:unit], 
              description: indicator[:description], updated_date: Time.now)
              # HANDLE CHANGE OF INDICATOR TYPE SINCE RANGES ALSO CHANGE
            if test_indicator.read_attribute_before_type_cast(:test_indicator_type) == indicator[:test_indicator_type]
              update_test_indicator_range(indicator[:indicator_ranges], test_indicator.id, indicator[:test_indicator_type])
            else
              test_indicator_ranges = TestIndicatorRange.where(test_indicator_id: test_indicator.id)
              test_indicator_ranges.each do |test_indicator_range|
                test_indicator_range.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: "Removed from test indicator", updated_date: Time.now)
              end
              if indicator[:test_indicator_type] == TestCatalog::TestIndicatorType::AUTO_COMPLETE || indicator[:test_indicator_type] == TestCatalog::TestIndicatorType::ALPANUMERIC
                TestCatalog::TestTypeCreateUtil.create_test_indicator_range_for_autocomplete(indicator[:indicator_ranges], test_indicator.id)
              elsif indicator[:test_indicator_type] == TestCatalog::TestIndicatorType::NUMERIC
                TestCatalog::TestTypeCreateUtil.create_test_indicator_range_for_numeric(indicator[:indicator_ranges], test_indicator.id)
              end
            end
          else
            TestCatalog::TestTypeCreateUtil.create_test_indicator(testtype_id, indicator)
          end
        end
        indicators_to_be_removed.each do |indicator|
          test_indicator = TestIndicator.find(indicator)
          test_indicator.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: "Removed from test type", updated_date: Time.now)
          test_indicator_range_to_be_removed_on_indicator_removal(test_indicator.id)
        end
      end

      def test_indicator_range_to_be_removed_on_indicator_removal(test_indicator_id)
        indicator_ranges_to_be_removed = TestIndicatorRange.where(test_indicator_id: test_indicator_id)
        indicator_ranges_to_be_removed.each do |indicator_range|
          indicator_range.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: "Removed from test indicator", updated_date: Time.now)
        end
      end

      def update_test_indicator_range_for_autocomplete(indicator_range_record, indicator_range_params)
        indicator_range_record.update!(value: indicator_range_params[:value], interpretation: indicator_range_params[:interpretation], updated_date: Time.now)
      end

      def update_test_indicator_range_for_numeric(indicator_range_record, indicator_range_params)
        indicator_range_record.update!(min_age: indicator_range_params[:min_age], max_age: indicator_range_params[:max_age], interpretation: indicator_range_params[:interpretation], 
          sex: indicator_range_params[:sex], lower_range: indicator_range_params[:lower_range], upper_range: indicator_range_params[:upper_range], updated_date: Time.now)
      end

    end
  end
end