# frozen_string_literal: true

paeds_test_types = TestType.active_with_paediatric.pluck(:id)
cancer_test_types = TestType.active_with_cancer.pluck(:id)
paed = LabLocation.find_by_name('Paediatric Lab').id
cancer = LabLocation.find_by_name('cancer lab').id
puts 'Updating paeds tests...'
Test.where(test_type_id: paeds_test_types).update_all(lab_location_id: paed)
puts 'Updating cancer tests...'
Test.where(test_type_id: cancer_test_types).update_all(lab_location_id: cancer)
