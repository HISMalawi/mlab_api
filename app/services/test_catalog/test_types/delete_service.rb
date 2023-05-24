module TestCatalog
  module TestTypes
    module DeleteService
      class << self

        def void_test_type(test_type, reason)
          unless reason
            raise ActionController::ParameterMissing, 'retired_reason'
          end
          ExpectedTat.where(test_type_id: test_type.id).first.void(reason)
          test_type.void(reason)
          SpecimenTestTypeMapping.where(test_type_id: test_type.id).each do |specimen_test_type|
            specimen_test_type.void(reason)
          end
          TestTypeOrganismMapping.where(test_type_id: test_type.id).each do |test_type_organism|
            test_type_organism.void(reason)
          end
          TestIndicator.where(test_type_id: test_type.id).each do |test_indicator|
            test_indicator.void(reason)
            TestIndicatorRange.where(test_indicator_id: test_indicator.id).each do |indicator_range|
              indicator_range.void(reason)
            end
          end
        end
      
      end
    end
  end
end