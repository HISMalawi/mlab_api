require 'rest-client'

module Nlims
  class OrderService
    attr_accessor :base_url, :username, :password, :token

    def initialize(nlims_configs = {})
      nlims_configs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def authenticate
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
        puts response
        return nil if response['status'] == 401 && response['message'] == "order not available"
        build_query_order_by_tracking_number_response(response['data'])
    end

    def build_query_order_by_tracking_number_response(response)
      tests = response['tests']
      tests_ = []
      tests.each do |key, value|
        tests_ << {
          test_type: key,
          test_status: value
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
        specimen: details['sample_type'],
        order_status: details['specimen_status'],
        facility_section: details['order_location'],
        sending_facility: details['sending_lab'],
        receiving_facility: details['receiving_lab'],
        order_created_date: details['date_created'],
        priority: details['priority'],
        requested_by: details['requested_by'],
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
        }
      }
    end

    def merge_or_create_order(order)
      client_npid = ClientIdentifierType.where(name: 'npid').first
      npid = order[:patient_identifiers][:npid]
      npid ||= ""
      client_identifier_type_id = client_npid.nil? ? '' : client_npid.id
      client = ClientIdentifier.where(client_identifier_type_id: , value: npid).first
      unless client.nil?
        person = Person.find_or_create_by(first_name: order[:patient][:first_name], last_name: order[:patient][:last_name], 
          middle_name: order[:patient][:middle_name], sex: order[:patient][:sex], 
          date_of_birth: order[:patient][:date_of_birth]
        )
        person.update(birth_date_estimated: false)
        client = Client.find_or_create_by(person_id: person.id)
      end
      
    end

  end
end