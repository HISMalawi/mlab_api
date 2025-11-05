# frozen_string_literal: true

require 'rest-client'

# module machine service
module MachineService
  # machine ProcessGexResults
  module ProcessGexResultsService
    class << self
      def process(accession_number:, machine_name:, measure_name:, result:)
        GENEXPERT_LOGGER.debug("Processing Data from CIHEB === Accession Number: #{accession_number}, Machine name: #{machine_name}, Measure Name: #{measure_name}, Result: #{result} ===")
        GENEXPERT_LOGGER.debug('====== Mapping measure name via config/gx_mapping.json mapping file ======')
        mapped_measure = map_measure_name(measure_name)
        GENEXPERT_LOGGER.debug("Mapped measure outcome: #{mapped_measure}")
        GENEXPERT_LOGGER.debug('====== Mapping to iblis measures ======')
        measure_unscoped = TestIndicator.unscoped.find_by(id: mapped_measure[:id]) || TestIndicator.unscoped.find_by(nlims_code: mapped_measure[:id])
        test_indicators = TestIndicator.where(nlims_code: measure_unscoped&.nlims_code) if measure_unscoped&.nlims_code.present?
        test_indicators ||= TestIndicator.where(name: mapped_measure[:name])
        test_indicators ||= TestIndicator.where(id: mapped_measure[:id]) if test_indicators.blank?
        test_indicators ||= TestIndicator.where(nlims_code: mapped_measure[:id]) if test_indicators.blank?
        if test_indicators.empty?
          GENEXPERT_LOGGER.error("No measures found for mapped measure: #{mapped_measure[:name]} (id: #{mapped_measure[:id]}) \n\n\n")
          return
        end
        GENEXPERT_LOGGER.debug("Mapped to indicators: #{test_indicators.map do |ti|
          "#{ti.name}(id: #{ti.id})"
        end.join(', ')}")
        GENEXPERT_LOGGER.debug('====== Saving results to IBLIS ======')
        test_indicators.each do |test_indicator|
          GENEXPERT_LOGGER.debug("Saving result for indicator: #{test_indicator.id} - #{test_indicator.name}")
          MachineService::WriteService.new(
            accession_number: accession_number,
            machine_name: machine_name,
            measure_id: test_indicator.id,
            result: result
          ).write
        end
        GENEXPERT_LOGGER.debug("====== Saving results to IBLIS complete ======\n\n\n")
      rescue StandardError => e
        GENEXPERT_LOGGER.error("Error processing #{accession_number}: #{e.message}")
        raise
      end

      def map_measure_name(measure_name)
        return { name: nil, id: nil } if measure_name.blank?

        mapping = JSON.parse(File.read("#{Rails.root}/config/gx_mapping.json"))
        alias_to_key = {}
        mapping.each do |key, data|
          data['aliases'].each do |alias_name|
            alias_to_key[alias_name.downcase] = { name: key, id: data['id'] }
          end
          # Also allow direct matching with canonical name
          alias_to_key[key.downcase] = { name: key, id: data['id'] }
        end
        normalized_name = measure_name.strip.downcase
        alias_to_key.fetch(normalized_name, { name: measure_name, id: nil })
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
          method: :get,
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
