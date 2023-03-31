module TestCatalog
  module TestType
    module ShowService
      class << self

        def show_test_type(test_type)
          specimens = SpecimenTestTypeMapping.joins(:specimen).where(test_type_id: test_type.id).select('specimen.id, specimen.name')
          {
            id: test_type.id,
            name: test_type.name,
            short_name: test_type.short_name,
            expected_turn_around_time: test_type.expected_turn_around_time,
            created_date: test_type.created_date,
            retired: test_type.retired,
            retired_reason: test_type.retired_reason,
            department_id: Department.select(:id, :name).find(test_type.department_id),
            specimens: specimens,
            organisms: serialize_test_type_organism(test_type.id),
            indicators: serialize_test_indicators(test_type.id)
          }
        end
  
        def serialize_test_indicators(test_type_id)
          serialized_test_indicators = []
          test_indicators = TestIndicator.where(test_type_id: test_type_id)
          test_indicators.each do |test_indicator|
            test_indicator_ranges = TestIndicatorRange.where(test_indicator_id: test_indicator.id)
            serialized_test_indicators.push({
              id: test_indicator.id,
              name: test_indicator.name,
              test_indicator_type: {
                id: test_indicator.read_attribute_before_type_cast(:test_indicator_type),
                name: test_indicator.test_indicator_type.gsub('_', ' ').titleize,
              },
              unit: test_indicator.unit,
              description: test_indicator.description,
              retired: test_indicator.retired,
              retired_reason: test_indicator.retired_reason,
              indicator_ranges: test_indicator_ranges
            })
          end
          serialized_test_indicators
        end
  
        def serialize_test_type_organism(test_type_id)
          test_type_organisms = TestTypeOrganismMapping.where(test_type_id: test_type_id)
          organisms = []
          test_type_organisms.each do |test_type_organism|
            organism = Organism.find(test_type_organism.id)
            organisms.push({
              name: organism.name,
              description: organism.description,
              retired: test_type_organism.retired,
              retired_reason: test_type_organism.retired_reason
            })
          end
          organisms
        end  

      end
    end
  end
end