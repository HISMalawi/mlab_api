# frozen_string_literal: true

require_relative 'clients'
require_relative 'encounters'
require_relative 'orders'
require_relative 'tests'
require_relative 'test_results'
require_relative 'culture_observations'
require_relative 'drug_suscept'
require_relative 'print_trails'

def last_record
  puts 'Enter last acession number from mlab:'
  accession_number = gets.chomp
  record = Order.where(accession_number:).first
  # debugger
  if record.nil?
    puts "\nPlease enter the valid accession number!!!\n\n"
    last_record
  else
    date = record.created_date.to_date
    total_orders = Order.where("DATE(created_date) BETWEEN '#{date - 10}' AND '#{date}'").count
    accession_number = Order.where(id: (record.id - (total_orders + 100))).first&.accession_number
    Order.joins(:tests, :encounter).where(accession_number:)
                             .select('orders.id, tests.id as test_id, encounters.client_id').first
  end
end

last_record = last_record()
client_id = last_record.client_id
test_id = last_record.test_id
order_id = last_record.id

Clients.process_clients(client_id)
Encounters.process_encounters(test_id)
Orders.process_orders(order_id)
Tests.process_tests(test_id)
TestResults.process_test_results(test_id)
CultureObservations.process_cs_observations(test_id)
DrugSuscept.process_drug_susceptibilities(test_id)
PrintTrails.process_print_trails(order_id)

# update locations
paeds_test_types = TestType.active_with_paediatric.pluck(:id)
cancer_test_types = TestType.active_with_cancer.pluck(:id)
paed = LabLocation.find_by_name('Paediatric Lab').id
cancer = LabLocation.find_by_name('cancer lab').id
puts 'Updating paeds tests...'
Test.where(test_type_id: paeds_test_types).where("id >= #{test_id}").update_all(lab_location_id: paed)
orders_ids = Test.where(test_type_id: paeds_test_types).where("id >= #{test_id}").pluck(:order_id)
encounters_ids = Order.where(id: orders_ids)
clients_ids = Encounter.where(id: encounters_ids)
Client.where(id: clients_ids).update_all(lab_location_id: paed)
puts 'Updating cancer tests...'
Test.where(test_type_id: cancer_test_types).where("id >= #{test_id}").update_all(lab_location_id: cancer)
orders_ids = Test.where(test_type_id: cancer_test_types).where("id >= #{test_id}").pluck(:order_id)
encounters_ids = Order.where(id: orders_ids)
clients_ids = Encounter.where(id: encounters_ids)
Client.where(id: clients_ids).update_all(lab_location_id: cancer)
puts 'Refreshing home analystics ...'
HomeDashboard.delete_all
HomeDashboardJob.perform_async
puts 'Done updating'
