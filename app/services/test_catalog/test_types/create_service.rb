module TestCatalog
  module TestTypes
    module CreateService
      class << self

        def create_test_type(test_type_params, params)
          ActiveRecord::Base.transaction do
            test_type = TestType.create!(test_type_params)
            expected_tat = params.require(:expected_turn_around_time)
            ExpectedTat.create!(
              test_type_id: test_type.id,
              value: expected_tat[:value],
              unit: expected_tat[:unit]
            )
            create_specimen_test_type_mapping(test_type.id, params[:specimens])
            params[:indicators].each do |indicator_param|
              create_test_indicator(test_type.id, indicator_param)
            end
            create_test_type_organism_mapping(test_type.id, params[:organisms])
            test_type
          end
        end

        def create_test_indicator(test_type_id, indicator_param)
          indicator_param[:test_type_id] = test_type_id
          test_indicator = TestIndicator.create!(JSON.parse(indicator_param.to_json).slice('name','unit','description','test_indicator_type', 'test_type_id'))
          create_test_indicator_range(indicator_param[:indicator_ranges], test_indicator.id, indicator_param[:test_indicator_type])
        end

        def create_test_indicator_range(test_indicator_ranges, test_indicator_id, test_indicator_type)
          if [TestCatalog::TestTypes::TestIndicatorType::AUTO_COMPLETE, TestCatalog::TestTypes::TestIndicatorType::ALPANUMERIC].include? test_indicator_type
            check_indicator_range_params(test_indicator_ranges)
            test_indicator_ranges.each do |test_indicator_range|
              create_test_indicator_range_for_autocomplete(test_indicator_range, test_indicator_id)
            end
          elsif test_indicator_type == TestCatalog::TestTypes::TestIndicatorType::NUMERIC
            check_indicator_range_params(test_indicator_ranges)
            test_indicator_ranges.each do |test_indicator_range|
              create_test_indicator_range_for_numeric(test_indicator_range, test_indicator_id)
            end
          end
        end

        def create_test_indicator_range_for_autocomplete(test_indicator_range, test_indicator_id)
          test_indicator_range[:test_indicator_id] = test_indicator_id
          TestIndicatorRange.create!(JSON.parse(test_indicator_range.to_json))
        end
  
        def create_test_indicator_range_for_numeric(test_indicator_range, test_indicator_id)
          test_indicator_range[:test_indicator_id] = test_indicator_id
          TestIndicatorRange.create!(JSON.parse(test_indicator_range.to_json))
        end

        def check_indicator_range_params(test_indicator_ranges)
          unless test_indicator_ranges && test_indicator_ranges.is_a?(Array)
            raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for indicator_ranges"
          end
        end

        def create_specimen_test_type_mapping(test_type_id, specimen_ids)
          specimen_ids.each do |specimen_id|
            SpecimenTestTypeMapping.create!(specimen_id: specimen_id, test_type_id: test_type_id)
          end
        end
  
        def create_test_type_organism_mapping(test_type_id, organism_ids)
          if organism_ids && organism_ids.is_a?(Array)
            organism_ids.each do | organism |
              TestTypeOrganismMapping.create!(organism_id: organism, test_type_id: test_type_id)
            end
          else
            raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for organisms" 
          end
        end

      end
    end
  end
end