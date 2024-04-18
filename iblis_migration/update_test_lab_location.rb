# frozen_string_literal: true

paeds_test_types = TestType.active_with_paediatric.pluck(:id)
cancer_test_types = TestType.active_with_cancer.pluck(:id)
paed = LabLocation.find_by_name('Paediatric Lab').id
cancer = LabLocation.find_by_name('cancer lab').id
puts 'Updating paeds tests...'
Test.where(test_type_id: paeds_test_types).update_all(lab_location_id: paed)
orders_ids = Test.where(test_type_id: paeds_test_types).pluck(:order_id)
encounters_ids = Order.where(id: orders_ids)
clients_ids = Encounter.where(id: encounters_ids)
Client.where(id: clients_ids).update_all(lab_location_id: paed)
puts 'Updating cancer tests...'
Test.where(test_type_id: cancer_test_types).update_all(lab_location_id: cancer)
orders_ids = Test.where(test_type_id: cancer_test_types).pluck(:order_id)
encounters_ids = Order.where(id: orders_ids)
clients_ids = Encounter.where(id: encounters_ids)
Client.where(id: clients_ids).update_all(lab_location_id: cancer)
puts 'Refreshing home analystics ...'
HomeDashboard.delete_all
HomeDashboardJob.perform_async
puts 'Done updating'
