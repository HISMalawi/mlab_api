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
  if record.nil?
    puts "\nPlease enter the valid accession number!!!\n\n"
    last_record
  else
    date = record.created_date.to_date
    accession_number = Order.where("DATE(created_date) BETWEEN '#{date - 4}' AND '#{date}'").first&.accession_number
    last_iblis_record = Order.joins(:tests, :encounter).where(accession_number:)
                           .select('orders.id, tests.id as test_id, encounters.client_id').first
    last_iblis_record
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
