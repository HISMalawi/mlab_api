module TestCatalog
  module TestTypeService
    class << self
      def create(params)
        begin
          create_response = ""
          testtype = ""
          ActiveRecord::Base.transaction do 
            testtype = TestType.new(name: params[:name], short_name: params[:short_name], department_id: params[:department_id],
              expected_turn_around_time: params[:expected_turn_around_time], retired: 0, creator: User.current.id,
              created_date: Time.now, updated_date: Time.now)
            if testtype.save!
              TestCatalog::TestTypeCreateUtil.create_specimen_test_type_mapping(testtype.id, params[:specimens])
              create_response = TestCatalog::TestTypeCreateUtil.perform_create_test_indicator(testtype.id, params[:indicators])
            end
          end
          if create_response[:status] 
            create_response[:test_type] = testtype
            return create_response
          end
        rescue => e
          return {status: false, error: e.message, msg: "unsuccessful"}
        end
      end

      # def update(testtype, params)
      #   TestCatalog::TestTypeUpdateUtil.update_test_type(testtype, params)
      #   TestCatalog::TestTypeUpdateUtil.update_specimen_test_type_mapping(testtype.id, params[:specimens])
      #   TestCatalog::TestTypeUpdateUtil.update_test_indicator(testtype.id, params[:indicators])
      # end

      def delete(testtype, retired_reason)
        testtype.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: retired_reason, updated_date: Time.now)
        specimens = SpecimenTestTypeMapping.where(test_type_id: testtype.id, retired: 0)
        specimens.each do |specimen|
          specimen.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: retired_reason, updated_date: Time.now)
        end
        test_indicators = TestIndicator.where(test_type_id: testtype.id, retired: 0)
        test_indicators.each do |test_indicator|
          test_indicator.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: retired_reason, updated_date: Time.now)
          test_indicator_ranges = TestIndicatorRange.where(test_indicator_id: test_indicator.id, retired: 0)
          test_indicator_ranges.each do |indicator_range|
            indicator_range.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: retired_reason, updated_date: Time.now)
          end
        end
      end

      def show(test_type)
        serialize(test_type)
      end

      def serialize(test_type)
        specimens = SpecimenTestTypeMapping.joins(:specimen).where(test_type_id: test_type.id, retired: 0).select('specimen.id, specimen.name')
        {
          name: test_type.name,
          short_name: test_type.short_name,
          expected_turn_around_time: test_type.expected_turn_around_time,
          created_date: test_type.created_date,
          retired: test_type.retired,
          department: Department.select(:id, :name).find(test_type.department_id),
          specimens: specimens,
          indicators: serialize_indicators(test_type.id)
        }
      end

      def serialize_indicators(testtype_id)
        serialize_indicators = []
        indicators = TestIndicator.where(test_type_id: testtype_id)
        indicators.each do |indicator|
          indicator_ranges = TestIndicatorRange.where(test_indicator_id: indicator.id)
          serialize_indicators.push({
            id: indicator.id,
            name: indicator.name,
            test_indicator_type: indicator.test_indicator_type,
            unit: indicator.unit,
            description: indicator.description,
            indicator_ranges: indicator_ranges
          })
        end
        return serialize_indicators
      end

    end
  end
end