module TestCatalog
  module TestTypeCreateUtil    
    def update_test_type(testtype, params)
      testtype.update(name: params[:name], short_name: params[:short_name], department_id: params[:department_id],
        expected_turn_around_time: params[:expected_turn_around_time], updated_date: Time.now)
    end

    def update_specimen_test_type_mapping(testtype_id, specimen_ids)
      specimen_record_ids = SpecimenTestTypeMapping.where(test_type_id: testtype_id, retired: 0).pluck('specimen_id')
      specimen_to_be_removed = specimen_record_ids - specimen_ids
      specimen_to_be_mapped = specimen_ids - specimen_record_ids
      if specimen_record_ids.sort == specimen_ids
        return {status: true, error: false}
      end
      begin
        ActiveRecord::Base.transaction do 
          if !specimen_to_be_removed.empty?
            specimen_to_be_removed.each do |specimen_id|
              specimen_test_type_mapping = SpecimenTestTypeMapping.where(specimen_id: specimen_id, test_type_id: testtype_id, retired: 0).first
              specimen_test_type_mapping.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: 'Removed from test type', updated_date: Time.now)
            end
          end
          if !specimen_to_be_mapped.empty?
            create_specimen_test_type_mapping(testtype_id, specimen_to_be_mapped)
          end
        end
        return {status: true, error: false}
      rescue => e
        return {status: false, error: e.message}
      end
    end

    def update_test_indicator_range(indicator_ranges, test_indicator_id, test_indicator_type)
      indicator_ranges.each do |indicator_range|
        if indicator_range.has_key?('id')
          test_indicator_range = TestIndicatorRange.find(indicator_range[:id])
          if test_indicator_type == TestCatalog::TestTypeUtil::AUTO_COMPLETE || test_indicator_type == TestCatalog::TestTypeUtil::ALPANUMERIC
            test_indicator_range.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: 'Removed from test indicator', updated_date: Time.now)
            create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
          elsif test_indicator_type == TestCatalog::TestTypeUtil::NUMERIC
            test_indicator_range.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: 'Removed from test indicator', updated_date: Time.now)
            create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
          end
        else
          if test_indicator_type == TestCatalog::TestTypeUtil::AUTO_COMPLETE || test_indicator_type == TestCatalog::TestTypeUtil::ALPANUMERIC
            create_test_indicator_range_for_autocomplete(indicator_range, test_indicator_id)
          elsif test_indicator_type == TestCatalog::TestTypeUtil::NUMERIC
            create_test_indicator_range_for_numeric(indicator_range, test_indicator_id)
          end
        end
      end
    end

    def update_test_indicator(testtype_id, indicators)
      indicators.each do |indicator|
        if indicator.has_key?('id')
          test_indicator = TestIndicator.find(indicator[:id])
          test_indicator.update(name: indicator[:name], test_indicator_type: indicator[:test_indicator_type], 
            unit: indicator[:unit], description: indicator[:description], updated_date: Time.now)
            update_test_indicator_range(indicator[:indicator_ranges], test_indicator.id, indicator[:test_indicator_type])
        else
          create_test_indicator(testtype_id, indicator)
        end
      end
    end
    
  end
end