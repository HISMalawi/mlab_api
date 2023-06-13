require 'rest-client'

module Nlims
  class RemoteService
    attr_accessor :base_url, :username, :password, :token

    def initialize(nlims_configs = {})
      nlims_configs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def ping_nlims
      begin
        RestClient::Request.execute(
          method: :get,
          url: "#{base_url }/api/v1/authenticate/#{username}/#{password}",
          headers: { content_type: :json, accept: :json }
        )
        true
      rescue Errno::ECONNREFUSED
        false
      end
    end

    def authenticate
      begin
        response = RestClient::Request.execute(
          method: :get,
          url: "#{base_url }/api/v1/authenticate/#{username}/#{password}" ,
          headers: { content_type: :json, accept: :json }
        )
        response = JSON.parse(response.body)
        raise RestClient::Unauthorized if response['status'] == 401
        return false if response['status'] != 200
        self.token = response['data']['token']
        re_authenticate
        true
      rescue RestClient::Unauthorized
        false
      end 
    end


    def re_authenticate
      response = RestClient::Request.execute(
                method: :get,
                url: "#{base_url }/api/v1/re_authenticate/#{username}/#{password}" ,
                headers: { content_type: :json, accept: :json }
              )
      response = JSON.parse(response.body)
      return false if response['status'] != 200
      self.token = response['data']['token']
      true
    end

    def query_order_by_tracking_number(tracking_number)
        response = RestClient::Request.execute(
                  method: :get,
                  url: "#{base_url }/api/v1/query_order_by_tracking_number/#{tracking_number}" ,
                  headers: { content_type: :json, accept: :json , 'token': "#{token}"}
                )
        response = JSON.parse(response.body)
        return nil if response['status'] == 401
        build_query_order_by_tracking_number_response(response['data'], tracking_number)
    end

    def query_results_by_tracking_number(tracking_number)
      response = RestClient::Request.execute(
        method: :get,
        url: "#{base_url }/api/v1/query_results_by_tracking_number/#{tracking_number}" ,
        headers: { content_type: :json, accept: :json , 'token': "#{token}"}
      )
      response = JSON.parse(response.body)
      response['message'] == 'results not available' ? [] : response['data']['results']
    end

    def build_query_order_by_tracking_number_response(response, tracking_number)
      tests = response['tests']
      tests_ = []
      tests.each do |key, value|
        tests_ << {
          test_type: key,
          test_status: value,
        }
      end
      details = response['other']
      name = details['patient']['name']
      name = name.split(' ')
      if name.length > 2
        first_name = name[0]
        middle_name = [1]
        last_name = [2]
      else
        first_name = name[0]
        middle_name = ''
        last_name = name[1]
      end
      order_details = {
        tests: tests_,
        tracking_number: tracking_number,
        specimen: details['sample_type'],
        order_status: details['specimen_status'],
        facility_section: details['order_location'],
        sending_facility: details['sending_lab'],
        receiving_facility: details['receiving_lab'],
        order_created_date: details['date_created'],
        priority: details['priority'],
        requested_by: details['requested_by'],
        collected_by: details['sample_created_by']['name'], 
        patient_identifiers: {
          art_regimen: details['art_regimen'],
          arv_number: details['arv_number'],
          art_start_date: details['art_start_date'],
          npid: details['patient']['id'],
        },
        patient: {
          first_name: first_name,
          middle_name: middle_name,
          last_name: last_name,
          sex: details['patient']['gender'],
          date_of_birth: details['patient']['dob']
        },
        results: query_results_by_tracking_number(tracking_number)
      }
    end

    def merge_or_create_order(nlims_order)
      raise_nlims_exception(nlims_order)
      client = find_or_create_client(nlims_order)
      facility_details = load_facility_details_from_nlims(nlims_order)
      order = Order.where(tracking_number: nlims_order[:tracking_number]).first
      if order.nil?
        encounter = create_encounter_from_nlims(client.id, facility_details, nlims_order[:priority])
        order = create_order_from_nlims(encounter.id, nlims_order)
        set_order_status_to_accepted(order.id)
        specimen = Specimen.find_by_name(nlims_order[:specimen])
        create_test_from_nlims(order.id, nlims_order[:tests], specimen.id, nlims_order[:results])
        save_results_from_nlims(order.id, nlims_order[:results]) unless nlims_order[:results].empty?
      end
      order
    end

    def save_results_from_nlims(order_id, results)
      tests = Test.where(order_id:)
      tests.each do |test|
        result = results["#{test.test_type.name}"]
        result.each do |key, value|
          if key != 'result_date'
            test_indicator = TestIndicator.find_by_name(key)
            TestResult.create!(test_id: test.id, test_indicator_id: test_indicator.id, value:,
              result_date: result['result_date'])
          end
        end
      end
    end

    def find_or_create_client(nlims_order)
      client_npid = ClientIdentifierType.where(name: 'npid').first
      npid = nlims_order[:patient_identifiers][:npid]
      npid ||= ""
      client_identifier_type_id = client_npid.nil? ? '' : client_npid.id
      client_identifier = ClientIdentifier.where(client_identifier_type_id: , value: npid).first
      if client_identifier.nil?
        person = Person.find_or_create_by(first_name: nlims_order[:patient][:first_name], last_name: nlims_order[:patient][:last_name], 
          middle_name: nlims_order[:patient][:middle_name], sex: nlims_order[:patient][:sex], 
          date_of_birth: nlims_order[:patient][:date_of_birth]
        )
        person.update(birth_date_estimated: false, date_of_birth: nlims_order[:patient][:date_of_birth])
        client = Client.find_or_create_by(person_id: person.id)
      else
        client = Client.find(client_identifier.id)
      end
    end

    def set_order_status_to_accepted(order_id)
      specimen_accepted = Status.find_by_name('specimen-accepted')
      OrderStatus.find_or_create_by!(order_id:, status_id: specimen_accepted.id)
    end

    def set_test_status(test_id, status_id)
      TestStatus.find_or_create_by!(test_id:, status_id: )
    end

    def check_specimen(specimen)
      sp = Specimen.find_by_name(specimen)
      sp.nil? ? false : true
    end

    def check_test_type(test_type)
      test_type = TestType.find_by_name(test_type)
      test_type.nil? ? false : true
    end

    def raise_nlims_exception(nlims_order)
      raise NlimsError, "Specimen: #{nlims_order[:specimen]} from nlims not available in mlab" unless check_specimen(nlims_order[:specimen])
      nlims_order[:tests].each do |test_|
        raise NlimsError, "Test type: #{test_[:test_type]} from nlims not available in mlab" unless check_test_type(test_[:test_type])
      end
    end

    def load_facility_details_from_nlims(nlims_order)
      f_section = nlims_order[:facility_section]
      f_section ||= "OPD"
      {
        facility_section: FacilitySection.find_or_create_by(name: f_section).id,
        sending_facility: Facility.find_or_create_by(name: nlims_order[:sending_facility]).id,
        destination_facility: Facility.find_or_create_by(name: nlims_order[:receiving_facility]).id
      }
    end

    def priority(prior)
      priority = prior
      priority ||= "Routine"
      Priority.find_or_create_by(name: priority).id
    end

    def create_encounter_from_nlims(client_id, facility_details, priority)
      encounter_type_id = EncounterType.find_or_create_by(name: 'Referral').id
      Encounter.create!(client_id: , facility_id: facility_details[:sending_facility],
        destination_id: facility_details[:destination_facility],
        facility_section_id: facility_details[:facility_section],
        start_date: Time.now,
        encounter_type_id:
      )
    end

    def create_order_from_nlims(encounter_id, nlims_order)
      Order.create!(encounter_id: , 
        priority_id: priority(nlims_order[:priority]),
        accession_number: OrderService.generate_accession_number,
        tracking_number: nlims_order[:tracking_number],
        requested_by: nlims_order[:requested_by],
        sample_collected_time: nlims_order[:order_created_date],
        collected_by: nlims_order[:collected_by]
      )
    end

    def create_test_from_nlims(order_id, tests, specimen_id, results)
      tests.each do |test_|
        test_type = TestType.find_by_name(test_[:test_type])
        test_panel = TestPanel.find_by_name(test_[:test_type])
        if test_panel.nil?
          t_ = Test.create!(
            specimen_id: ,
            order_id: order_id,
            test_type_id: test_type.id
          )
          unless results.empty?
            status = Status.find_by_name(test_[:test_status])
            set_test_status(t_.id, status.id) if !status.nil?
          end
        else
          member_test_types = TestTypePanelMapping.joins(:test_type).where(test_panel_id: test_panel.id).pluck('test_types.id')
          member_test_types.each do |test_type|
            t_ = Test.create!(
              specimen_id: ,
              order_id: order_id,
              test_type_id: test_type,
              test_panel_id: test_panel.id
            )
            unless results.empty?
              status = Status.find_by_name(test_[:test_status])
              set_test_status(t_.id, status.id) if !status.nil?
            end
          end
        end
      end
    end

  end
end