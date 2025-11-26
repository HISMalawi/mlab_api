require 'rest-client'

module Nlims
  class RemoteService
    attr_accessor :base_url, :username, :password, :token, :enable_real_time_sync

    def initialize(nlims_configs = {})
      nlims_configs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def ping_nlims
      response = RestClient::Request.execute(
        method: :get,
        url: "#{base_url}/api/v1/ping",
        headers: { content_type: :json, accept: :json },
        timeout: 3
      )
      res = JSON.parse(response.body)
      res['ping']
    rescue Errno::ECONNREFUSED
      false
    rescue RestClient::InternalServerError
      false
    rescue StandardError
      false
    end

    def authenticate
      re_authenticate
    end

    def re_authenticate
      response = RestClient::Request.execute(
        method: :post,
        url: "#{base_url}/api/v1/login/",
        payload: { username:, password: }.to_json,
        headers: { content_type: :json, accept: :json },
        timeout: 3
      )
      response = JSON.parse(response.body)
      self.token = response['data']['token']
      true
    rescue StandardError
      false
    end

    def query_order_by_tracking_number(tracking_number)
      response = RestClient::Request.execute(
        method: :get,
        url: "#{base_url}/api/v2//orders/#{tracking_number}",
        headers: { content_type: :json, accept: :json, 'token': "#{token}" }
      )
      response = JSON.parse(response.body)
      response['data']
    rescue RestClient::NotFound
      nil
    rescue StandardError
      nil
    end

    # Main method to handle NLIMS payload structure
    def merge_or_create_order(nlims_payload)
      order_data = nlims_payload[:order] || nlims_payload['order']
      patient_data = nlims_payload[:patient] || nlims_payload['patient']
      tests_data = nlims_payload[:tests] || nlims_payload['tests']
      lab_location_id = nlims_payload[:lab_location] || nlims_payload['lab_location']

      raise_nlims_exception(order_data, tests_data)
      client = find_or_create_client(patient_data)
      facility_details = load_facility_details_from_nlims(order_data)
      client_history = order_data[:clinical_history] || order_data['clinical_history']
      order = Order.where(tracking_number: order_data[:tracking_number] || order_data['tracking_number']).first
      if order.nil?
        encounter = create_encounter_from_nlims(client.id, facility_details,
                                                order_data[:priority] || order_data['priority'],
                                                client_history)
        order = create_order_from_nlims(encounter.id, order_data)
        set_order_status_to_accepted(order.id)

        # Find specimen using nlims_code only
        sample_type = order_data[:sample_type] || order_data['sample_type']
        specimen = find_specimen_by_nlims_code(sample_type)

        create_tests_from_nlims(order.id, tests_data, specimen.id, lab_location_id)
      end
      order
    end

    def sexify(sex)
      if sex.downcase == 'female'
        sex = 'F'
      elsif sex.downcase == 'male'
        sex = 'M'
      end
      sex
    end

    def set_order_status_to_accepted(order_id)
      specimen_accepted = Status.find_by_name('specimen-accepted')
      Order.find(order_id).update(status_id: specimen_accepted.id)
      OrderStatus.find_or_create_by!(order_id:, status_id: specimen_accepted.id)
    end

    def set_test_status(test_id, status_id)
      TestStatus.find_or_create_by!(test_id:, status_id:)
    end

    # Helper methods for v2 implementation
    def find_specimen_by_nlims_code(sample_type)
      nlims_code = sample_type[:nlims_code] || sample_type['nlims_code']

      raise NlimsError, "NLIMS code is required for specimen lookup: #{sample_type}" if nlims_code.blank?

      specimen = Specimen.find_by(nlims_code: nlims_code)
      raise NlimsError, "Specimen not found for NLIMS code: #{nlims_code}" if specimen.nil?

      specimen
    end

    def find_test_type_by_nlims_code(test_type_data)
      nlims_code = test_type_data[:nlims_code] || test_type_data['nlims_code']

      return nil if nlims_code.blank?

      TestType.find_by(nlims_code: nlims_code)
    end

    def find_test_indicator_by_nlims_code(measure_data)
      nlims_code = measure_data[:nlims_code] || measure_data['nlims_code']

      return nil if nlims_code.blank?

      TestIndicator.find_by(nlims_code: nlims_code)
    end

    def raise_nlims_exception(order_data, tests_data)
      sample_type = order_data[:sample_type] || order_data['sample_type']
      find_specimen_by_nlims_code(sample_type) # This will raise an error if specimen not found

      tests_data.each do |test_data|
        test_type_data = test_data[:test_type] || test_data['test_type']
        test_type = find_test_type_by_nlims_code(test_type_data)

        if test_type.nil?
          nlims_code = test_type_data[:nlims_code] || test_type_data['nlims_code'] || 'Unknown'
          raise NlimsError, "Test type with NLIMS code: #{nlims_code} from nlims not available in mlab"
        end
      end
    end

    def find_or_create_client(patient_data)
      client_npid = ClientIdentifierType.where(name: 'npid').first
      npid = patient_data[:national_patient_id] || patient_data['national_patient_id'] || ''
      client_identifier_type_id = client_npid.nil? ? '' : client_npid.id
      client_identifier = ClientIdentifier.where(client_identifier_type_id:, value: npid).first

      if client_identifier.nil?
        sex = sexify(patient_data[:gender] || patient_data['gender'])
        person = Person.find_or_create_by(
          first_name: patient_data[:first_name] || patient_data['first_name'],
          last_name: patient_data[:last_name] || patient_data['last_name'],
          middle_name: '',
          sex:,
          date_of_birth: patient_data[:date_of_birth] || patient_data['date_of_birth']
        )
        person.update(birth_date_estimated: false,
                      date_of_birth: patient_data[:date_of_birth] || patient_data['date_of_birth'])
        Client.find_or_create_by(person_id: person.id)
      else
        Client.find(client_identifier.id)
      end
    end

    def load_facility_details_from_nlims(order_data)
      f_section = order_data[:order_location] || order_data['order_location'] || 'OPD'
      sending_facility = order_data[:sending_facility] || order_data['sending_facility'] || 'Unknown'
      target_lab = order_data[:target_lab] || order_data['target_lab'] || sending_facility

      {
        facility_section: FacilitySection.find_or_create_by(name: f_section).id,
        sending_facility: Facility.find_or_create_by(name: sending_facility).id,
        destination_facility: Facility.find_or_create_by(name: target_lab).id
      }
    end

    def create_encounter_from_nlims(client_id, facility_details, _priority, client_history = nil)
      encounter_type_id = EncounterType.find_or_create_by(name: 'Referral').id
      Encounter.create!(
        client_id:,
        facility_id: facility_details[:sending_facility],
        destination_id: facility_details[:destination_facility],
        facility_section_id: facility_details[:facility_section],
        start_date: Time.now,
        encounter_type_id:,
        client_history:
      )
    end

    def create_order_from_nlims(encounter_id, order_data)
      Order.create!(
        encounter_id:,
        priority_id: priority(order_data[:priority] || order_data['priority']),
        accession_number: OrderService.generate_accession_number,
        tracking_number: order_data[:tracking_number] || order_data['tracking_number'],
        requested_by: order_data[:requested_by] || order_data['requested_by'],
        sample_collected_time: order_data[:date_created] || order_data['date_created'],
        collected_by: extract_drawn_by_name(order_data[:drawn_by] || order_data['drawn_by'])
      )
    end

    def priority(prior)
      priority = prior
      priority ||= 'Routine'
      Priority.find_or_create_by(name: priority).id
    end

    def extract_drawn_by_name(drawn_by_data)
      return '' if drawn_by_data.nil?

      drawn_by_data[:name] || drawn_by_data['name'] || ''
    end

    def create_tests_from_nlims(order_id, tests_data, specimen_id, lab_location_id)
      tests_data.each do |test_data|
        test_type_data = test_data[:test_type] || test_data['test_type']
        test_type = find_test_type_by_nlims_code(test_type_data)
        test_panel = TestPanel.find_by(name: test_type.name) if test_type

        # Use lab_location_id directly as it's already an ID
        location_id = lab_location_id || LabLocation.first&.id

        if test_panel.nil?
          test = Test.create!(
            specimen_id:,
            order_id:,
            test_type_id: test_type.id,
            lab_location_id: location_id
          )

          # Process status trail and results
          process_test_status_trail(test, test_data)
          process_test_results(test, test_data)
        else
          member_test_types = TestTypePanelMapping.joins(:test_type).where(test_panel_id: test_panel.id).pluck('test_types.id')
          member_test_types.each do |test_type_id|
            test = Test.create!(
              specimen_id:,
              order_id:,
              test_type_id:,
              test_panel_id: test_panel.id,
              lab_location_id: location_id
            )

            # Process status trail and results
            process_test_status_trail(test, test_data)
            process_test_results(test, test_data)
          end
        end
      end
    end

    def process_test_status_trail(test, test_data)
      status_trail = test_data[:status_trail] || test_data['status_trail'] || []

      status_trail.each do |status_entry|
        status_name = status_entry[:status] || status_entry['status']
        status = Status.find_by(name: status_name)
        next if status.nil?

        set_test_status(test.id, status.id)
        test.update(status_id: status.id)
      end

      # Set final status from test_status if available
      final_status_name = test_data[:test_status] || test_data['test_status']
      return unless final_status_name.present?

      final_status = Status.find_by(name: final_status_name)
      return unless final_status

      set_test_status(test.id, final_status.id)
      test.update(status_id: final_status.id)
    end

    def process_test_results(test, test_data)
      test_results = test_data[:test_results] || test_data['test_results'] || []

      test_results.each do |result_data|
        measure_data = result_data[:measure] || result_data['measure']
        result_info = result_data[:result] || result_data['result']

        test_indicator = find_test_indicator_by_nlims_code(measure_data)
        next if test_indicator.nil?

        TestResult.create!(
          test_id: test.id,
          test_indicator_id: test_indicator.id,
          value: result_info[:value] || result_info['value'],
          result_date: result_info[:result_date] || result_info['result_date'] || Time.now
        )
      end
    end
  end
end
