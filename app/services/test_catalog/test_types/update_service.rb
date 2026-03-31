module TestCatalog
  module TestTypes
    module UpdateService
      class IndicatorValidationError < StandardError
        attr_reader :indicator_id, :indicator_name, :field

        def initialize(msg, indicator_id:, indicator_name:, field:)
          super(msg)
          @indicator_id = indicator_id
          @indicator_name = indicator_name
          @field = field
        end
      end

      class << self
        def update_test_type(test_type, test_type_params, params)
          ActiveRecord::Base.transaction do
            expected_tat = params.require(:expected_turn_around_time)
            ExpectedTat.find_or_create_by!(test_type_id: test_type.id).update!(
              value: expected_tat[:value],
              unit: expected_tat[:unit]
            )
            test_type.update!(test_type_params)
            update_specimen_test_type_mapping(test_type.id, params[:specimens])
            update_test_type_organism_mapping(test_type.id, params[:organisms])
            update_test_indicator(test_type.id, params[:indicators])
          end
        end

        def update_specimen_test_type_mapping(test_type_id, specimen_ids)
          SpecimenTestTypeMapping.where(test_type_id:).where.not(specimen_id: specimen_ids).each do |specimen_test_type_mapping|
            specimen_test_type_mapping.void('Removed from test type')
          end
          specimen_ids.each do |specimen_id|
            SpecimenTestTypeMapping.find_or_create_by(test_type_id:, specimen_id:)
          end
        end

        def update_test_type_organism_mapping(test_type_id, organism_ids)
          TestTypeOrganismMapping.where(test_type_id:).where.not(organism_id: organism_ids).each do |test_type_organism_mapping|
            test_type_organism_mapping.void('Removed from test type')
          end
          organism_ids.each do |organism_id|
            TestTypeOrganismMapping.find_or_create_by(organism_id:, test_type_id:)
          end
        end

        def update_test_indicator_range(test_indicator_ranges, test_indicator_id, test_type_id, test_indicator_type)
          test_indicator_range_ids = test_indicator_ranges.each.with_object(:id).map(&:[])
          # Free text and rich text don't have ranges
          if %w[rich_text free_text].include?(test_indicator_type)
            test_indicator_range_ids = []
            test_indicator_ranges = []
          end
          # Void ranges that are no longer in the list for this specific test_indicator AND test_type combination
          TestIndicatorRange.where(test_indicator_id: test_indicator_id, test_type_id: test_type_id)
                            .where.not(id: test_indicator_range_ids).each do |test_indicator_range|
            test_indicator_range.void('Removed from test indicator')
          end
          # Create or update ranges
          test_indicator_ranges.each do |test_indicator_range|
            test_indicator_range[:test_indicator_id] = test_indicator_id
            test_indicator_range[:test_type_id] = test_type_id
            test_indicator_range_attributes = JSON.parse(test_indicator_range.to_json)
            test_indicator_range = TestIndicatorRange.find_or_initialize_by(id: test_indicator_range_attributes['id'])
            test_indicator_range.update!(test_indicator_range_attributes)
          end
        end

        def update_test_indicator(test_type_id, test_indicator_params)
          # Void test indicator and its associated ranges
          test_indicator_ids = test_indicator_params.each.with_object(:id).map(&:[])
          TestTypeTestIndicator.where(test_types_id: test_type_id).where.not(test_indicators_id: test_indicator_ids).each do |test_type_test_indicator|
            test_type_test_indicator.void('Removed test type - test indicator mapping')
            # Void ranges for this specific test_type and test_indicator combination
            TestIndicatorRange.where(
              test_indicator_id: test_type_test_indicator.test_indicators_id,
              test_type_id: test_type_id
            ).each do |test_indicator_range|
              test_indicator_range.void('Removed from test indicator')
            end
          end
          # Update or create test indicators and its associated ranges
          test_indicator_params.each do |test_indicator_param|
            test_indicator_param[:test_indicator_type] = test_indicator_param[:test_indicator_type]['id']
            test_indicator_attributes = JSON.parse(test_indicator_param.to_json)
                                            .slice('id', 'name', 'description', 'preferred_name')
            test_indicator = TestIndicator.find_or_initialize_by(id: test_indicator_attributes['id'])
            begin
              test_indicator.update!(test_indicator_attributes)
            rescue ActiveRecord::RecordInvalid => e
              if test_indicator.errors[:preferred_name].any?
                raise IndicatorValidationError.new(
                  "Indicator \"#{test_indicator_attributes['name']}\" - Preferred name #{test_indicator.errors[:preferred_name].first}",
                  indicator_id: test_indicator_attributes['id'],
                  indicator_name: test_indicator_attributes['name'],
                  field: 'preferred_name'
                )
              end
              raise
            end
            test_indicator.reload
            testtype_indicator = TestTypeTestIndicator.find_or_create_by!(
              test_types_id: test_type_id,
              test_indicators_id: test_indicator.id
            )
            # Update the junction table with unit and test_indicator_type
            testtype_indicator.update!(
              test_indicator_type: test_indicator_param[:test_indicator_type],
              unit: test_indicator_param[:unit]
            )
            # Use test_indicator_type from params, not from test_indicator model
            indicator_type_name = get_indicator_type_name(test_indicator_param[:test_indicator_type])
            update_test_indicator_range(
              test_indicator_param[:indicator_ranges],
              test_indicator.id,
              test_type_id,
              indicator_type_name
            )
          end
        end

        def get_indicator_type_name(type_id)
          type_map = {
            0 => 'auto_complete',
            1 => 'free_text',
            2 => 'numeric',
            3 => 'alpha_numeric',
            4 => 'rich_text'
          }
          type_map[type_id] || 'numeric'
        end
      end
    end
  end
end
