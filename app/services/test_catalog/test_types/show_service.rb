module TestCatalog
  module TestTypes
    module ShowService
      class << self
        def show_test_type(test_type)
          {
            id: test_type.id,
            name: test_type.name,
            short_name: test_type.short_name,
            preferred_name: test_type.preferred_name,
            description: test_type.description,
            nlims_code: test_type.nlims_code,
            moh_code: test_type.moh_code,
            loinc_code: test_type.loinc_code,
            scientific_name: test_type.scientific_name,
            sex: test_type&.sex,
            expected_turn_around_time: test_type.expected_tats,
            print_device: test_type.print_device,
            created_date: test_type.created_date,
            retired: test_type.retired,
            retired_reason: test_type.retired_reason,
            department: Department.select(:id, :name, :preferred_name, :nlims_code).find(test_type.department_id),
            specimens: test_type.specimens,
            organisms: test_type.organisms,
            indicators: serialize_test_indicators(test_type.id)
          }
        end

        def serialize_test_indicators(test_type_id)
          serialized_test_indicators = []
          # Get the mappings which contain unit and test_indicator_type for this specific test type
          test_type_mappings = TestTypeTestIndicator.where(test_types_id: test_type_id, voided: [0, nil])

          test_type_mappings.each do |mapping|
            test_indicator = TestIndicator.find(mapping.test_indicators_id)
            test_indicator_ranges = TestIndicatorRange.where(test_indicator_id: test_indicator.id, test_type_id:,
                                                             retired: [0, nil])

            # Get test_indicator_type from mapping table if available, otherwise from indicator
            # Ensure we get the integer ID, not the string representation
            raw_type = mapping.test_indicator_type
            type_id = if raw_type.nil?
                        # Fall back to indicator's type
                        test_indicator.read_attribute_before_type_cast(:test_indicator_type)
                      else
                        # mapping.test_indicator_type should already be an integer
                        raw_type.is_a?(Integer) ? raw_type : TestTypeTestIndicator.test_indicator_types[raw_type.to_sym]
                      end

            # Ensure type_id is an integer
            type_id = type_id.to_i unless type_id.is_a?(Integer)

            type_name = %w[auto_complete free_text numeric alpha_numeric rich_text][type_id]&.gsub('_',
                                                                                                   ' ')&.titleize || 'Unknown'

            serialized_test_indicators.push({
                                              id: test_indicator.id,
                                              name: test_indicator.name,
                                              preferred_name: test_indicator.preferred_name,
                                              short_name: test_indicator.short_name,
                                              nlims_code: test_indicator.nlims_code,
                                              test_indicator_type: {
                                                id: type_id,
                                                name: type_name
                                              },
                                              unit: mapping.unit,
                                              retired: test_indicator.retired,
                                              retired_reason: test_indicator.retired_reason,
                                              indicator_ranges: test_indicator_ranges
                                            })
          end
          serialized_test_indicators
        end

        def serialize_test_type_organism(test_type_id)
          test_type_organisms = TestTypeOrganismMapping.where(test_type_id:)
          organisms = []
          test_type_organisms.each do |test_type_organism|
            organism = Organism.find(test_type_organism.organism_id)
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
