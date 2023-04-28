require 'rest-client'

module ClientManagement
  class DdeService
    attr_accessor :base_url, :username, :password, :token

    def initialize(dde_configs = {})
      dde_configs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def check_dde_status
      begin
        RestClient::Request.execute(
          method: :get,
          url: base_url,
          timeout: 3
        )
        true
      rescue RestClient::Unauthorized
        true
      rescue Errno::ECONNREFUSED
        false
      rescue RestClient::Exceptions::OpenTimeout
        false
      end
    end

    def authenticate
      begin
        response = RestClient::Request.execute(
                  method: :post,
                  url: "#{ base_url }/v1/login",
                  payload: { username: username, password: password }.to_json,
                  headers: { content_type: :json, accept: :json }
                )
        self.token = JSON.parse(response.body)['access_token']
        true
      rescue RestClient::UnAuthorized
        false
      end
    end

    def re_authenticate
      RestClient::Request.execute(
          method: :post,
          url: "#{ base_url }/v1/verify_token",
          headers: { 'Authorization': "#{token}" }
        ) do |response|
          return true if response.code == 200
          authenticate
        end
    end

    def search_client_by_name_and_gender(first_name, last_name, gender)
      if re_authenticate
        begin
          response = RestClient::Request.execute(
            method: :post, 
            url: "#{base_url}/v1/search_by_name_and_gender",
            headers: { 'Authorization': "#{token}" },
            payload: { given_name: first_name, family_name: last_name, gender: gender}
          )
          serialize_dde_clients(JSON.parse(response.body))
        rescue RestClient::NotFound
          []
        rescue RestClient::InternalServerError
          []
        end
      else
        []
      end
    end

    def serialize_dde_clients(clients)
      clients_array = []
      clients.each do |client|
        clients_array << {
          source: 'remote',
          first_name: client['given_name'],
          middle_name: client['middle_name'],
          last_name: client['family_name'],
          sex: client['gender'],
          date_of_birth: client['birthdate'],
          birth_date_estimated: client['birthdate_estimated'],
          uuid: client['doc_id'],
          npid: client['npid'],
          current_district: client['attributes']['current_district'],
          current_traditional_authority: client['attributes']['current_traditional_authority'],
          current_village: client['attributes']['current_village'],
          home_district: client['attributes']['home_district'],
          home_traditional_authority: client['attributes']['home_traditional_authority'],
          home_village: client['attributes']['home_village']
        }
      end
      clients_array
    end

    def create_client(params)
      payload = build_create_client_payload(params)
      response = RestClient::Request.execute(
        method: :post, 
        url: "#{base_url}v1/add_person",
        headers: { 'Authorization': "#{token}" },
        payload: payload
      )
      response
    end

    def build_create_client_payload(params)
      attributes = {}
      identifiers = {}
      params[:client_identifiers].each do |identifier|
        if ['art_number', 'htn_number'].include?.(identifier[:type])
          identifiers[identifier[:type]] = identifier[:value]
        else
          attributes[identifier[:type]] = identifier[:value]
        end
      end
      {
                given_name: params[:person][:first_name],
                family_name: params[:person][:last_name],
                middle_name: params[:person][:middle_name],
                gender: params[:person][:gender],
                birthdate: params[:person][:date_of_birth],
                birthdate_estimated: params[:person][:date_of_birth_estimated],
                attributes: attributes,
                identifiers: identifiers
      }
    end

  end
end

