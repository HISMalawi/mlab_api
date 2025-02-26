# frozen_string_literal: true

require 'rest-client'

# module machine service
module MachineService
  # machine ProcessGexResults
  module ProcessGexResultsService
    class << self
      def process(accession_number:, machine_name:, measure_name:, result:)
        test_indicators = TestIndicator.where(name: measure_name)
        test_indicators.each do |test_indicator|
          MachineService::WriteService.new(
            accession_number:,
            machine_name:,
            measure_id: test_indicator&.id,
            result:
          ).write
        end
      end

      def subscribe_to_gx_service
        application_yml = YAML.load_file("#{Rails.root}/config/application.yml")
        ciheb_gex_subscription = application_yml['ciheb_gex_subscription']
        payload = {
          app_name: ciheb_gex_subscription['app_name'],
          org_name: ciheb_gex_subscription['organization_name'],
          username: ciheb_gex_subscription['iblis_username'],
          password: ciheb_gex_subscription['iblis_password'],
          result_api: ciheb_gex_subscription['iblis_result_endpoint'],
          client_type: ciheb_gex_subscription['client_type'],
          port: ciheb_gex_subscription['iblis_backend_port'],
          ip_address: ciheb_gex_subscription['iblis_ip_address']
        }
        response = RestClient::Request.execute(
                method: :post,
                url: ciheb_gex_subscription['ciheb_eid_vl_enpoint'],
                payload: payload.to_json,
                headers: { content_type: :json, accept: :json }
              )
        puts response
      rescue StandardError => e
        puts "Unexpected Error: #{e.message}"
      end
    end
  end
end
