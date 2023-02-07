require 'test_helper'

class Api::V1::ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
  end

  test "should get index" do
    get api_v1_clients_url, as: :json
    assert_response :success
  end

  test "should create client" do
    assert_difference('Client.count') do
      post api_v1_clients_url, params: { client: { created_date: @client.created_date, creator: @client.creator, person_id: @client.person_id, updated_date: @client.updated_date, uuid: @client.uuid, voided: @client.voided, voided_by: @client.voided_by, voided_date: @client.voided_date, voided_reason: @client.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show client" do
    get api_v1_client_url(@client), as: :json
    assert_response :success
  end

  test "should update client" do
    patch api_v1_client_url(@client), params: { client: { created_date: @client.created_date, creator: @client.creator, person_id: @client.person_id, updated_date: @client.updated_date, uuid: @client.uuid, voided: @client.voided, voided_by: @client.voided_by, voided_date: @client.voided_date, voided_reason: @client.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy client" do
    assert_difference('Client.count', -1) do
      delete api_v1_client_url(@client), as: :json
    end

    assert_response 204
  end
end
