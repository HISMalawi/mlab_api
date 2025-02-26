# frozen_string_literal: true

namespace :gex_sub do
  desc 'TODO'
  task subscribe: :environment do
    puts 'Subscribing'
    MachineService::ProcessGexResultsService.subscribe_to_gx_service
  end
end
