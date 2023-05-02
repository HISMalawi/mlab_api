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
      begin
        response = RestClient::Request.execute(
                  method: :post,
                  url: "#{base_url }/api/v1/authenticate/#{username}/#{password}" ,
                  payload: { username: username, password: password }.to_json,
                  headers: { content_type: :json, accept: :json }
                )
        self.token = JSON.parse(response.body)['access_token']
        true
      rescue RestClient::UnAuthorized
        false
      end
    end

    def query_order_by_tracking_number(tracking_number)
      begin
        response = RestClient::Request.execute(
                  method: :post,
                  url: "#{base_url }/api/v1/query_order_by_tracking_number/#{tracking_number}" ,
                  payload: { username: username, password: password }.to_json,
                  headers: { content_type: :json, accept: :json }
                )
        self.token = JSON.parse(response.body)['access_token']
        true
      rescue RestClient::UnAuthorized
        false
      end
    end

  end
end