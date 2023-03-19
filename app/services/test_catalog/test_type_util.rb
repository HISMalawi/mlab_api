module TestCatalog
  module TestTypeUtil
    class << self
      def create_indicator(testtype, indicators)
        indicators.each do |indicator|
          test_indicator = TestIndicator.new(name: indicator[:name], test_type_id: testtype, test_indicator_type: indicator[:test_indicator_type], 
              unit: indicator[:unit], description: indicator[:description], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
          if test_indicator.save
            if !indicator[:indicator_ranges].empty?
              create_indicator_range(indicator[:indicator_ranges], test_indicator.id, indicator[:test_indicator_type])
            end
          end
        end
      end
      
      def create_indicator_range(indicator_ranges, test_indicator, test_indicator_type)
        if test_indicator_type == 0 || test_indicator_type == 3
          indicator_ranges.each do |indicator_range|
            TestIndicatorRange.create(test_indicator_id: test_indicator, value: indicator_range[:value], interpretation: indicator_range[:interpretation], retired: 0, 
              creator: User.current.id, created_date: Time.now, updated_date: Time.now)
          end
        elsif test_indicator_type == 2
          indicator_ranges.each do |indicator_range|
            TestIndicatorRange.create(test_indicator_id: test_indicator, min_age: indicator_range[:min_age], max_age: indicator_range[:max_age], interpretation: indicator_range[:interpretation], 
              retired: 0, sex: indicator_range[:sex], lower_range: indicator_range[:lower_range], upper_range: indicator_range[:upper_range], creator: User.current.id, created_date: Time.now, updated_date: Time.now)
          end
        end
      end

      def create_specimen_test_type_mapping(testtype, specimens)
        specimens.each do |specimen|
          SpecimenTestTypeMapping.create(specimen_id: specimen, test_type_id: testtype, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        end
      end
    end
  end
end