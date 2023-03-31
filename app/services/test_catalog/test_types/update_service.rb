module TestCatalog
  module TestTypes
    module UpdateService
      class << self
        
       def update_test_type(test_type, params)
          test_type.update!(**params)
          update_specimen_test_type_mapping(test_type.id, params[:specimens])
          update_test_type_organism_mapping(test_type.id, params[:organisms])
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

        def update_test_indicator_range(test_indicator_ranges, test_indicator_id, test_indicator_type)
          test_indicator_range_ids = test_indicator_ranges.each.with_object(:id).map(&:[])
          TestIndicatorRange.where(test_indicator_id:).where.not(id: test_indicator_range_ids).each do |test_indicator_range|
            test_indicator_range.void('Removed from test indicator')
          end
          test_indicator_ranges.each do |test_indicator_range|

          end
        end

        def update_test_indicator(test_type_id, test_indicator_params)
          # Void test indicator and its associated ranges
          test_indicator_ids = test_indicator_params.each.with_object(:id).map(&:[])
          TestIndicator.where(test_type_id: test_type_id).where.not(id: test_indicator_ids).each do |test_indicator|
            test_indicator.void('Removed from test type')
            TestIndicatorRange.where(test_indicator_id: test_indicator.id).each do |test_indicator_range|
              test_indicator_range.void('Removed from test indicator')
            end
          end
          # Update or create test indicators and its associated ranges
          test_indicator_ids.each do |test_indicator_id|
            test_indicator = TestIndicator.find_or_create_by(id: test_indicator_id)
            if test_indicator.read_attribute_before_type_cast(:test_indicator_type) == test_indicator_params[:test_indicator_type]

            end
          end
        end
  

      end
    end
  end
end