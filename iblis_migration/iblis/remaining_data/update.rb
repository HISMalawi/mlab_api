# frozen_string_literal: true

require_relative 'clients'
require_relative 'encounters'
require_relative 'orders'
require_relative 'tests'
require_relative 'test_results'
require_relative 'culture_observations'
require_relative 'drug_suscept'

client_id = 0
test_id = 0
order_id = 0
Clients.process_clients(client_id)
Encounters.process_encounters(test_id)
Orders.process_encounters(order_id)
Tests.process_encounters(test_id)
TestResults.process_test_results(test_id)
CultureObservations.process_cs_observations(test_id)
DrugSuscept.process_drug_susceptibilities(test_id)
