require 'test_helper'

class Api::V1::ClientIdentifiersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client_identifier = client_identifiers(:one)
  end

  test "should get index" do
    get api_v1_client_identifiers_url, as: :json
    assert_response :success
  end

  test "should create client_identifier" do
    assert_difference('ClientIdentifier.count') do
      post api_v1_client_identifiers_url, params: { client_identifier: { client_id: @client_identifier.client_id, client_identifier_type_id: @client_identifier.client_identifier_type_id, created_date: @client_identifier.created_date, creator: @client_identifier.creator, updated_date: @client_identifier.updated_date, uuid: @client_identifier.uuid, value: @client_identifier.value, voided: @client_identifier.voided, voided_by: @client_identifier.voided_by, voided_date: @client_identifier.voided_date, voided_reason: @client_identifier.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show client_identifier" do
    get api_v1_client_identifier_url(@client_identifier), as: :json
    assert_response :success
  end

  test "should update client_identifier" do
    patch api_v1_client_identifier_url(@client_identifier), params: { client_identifier: { client_id: @client_identifier.client_id, client_identifier_type_id: @client_identifier.client_identifier_type_id, created_date: @client_identifier.created_date, creator: @client_identifier.creator, updated_date: @client_identifier.updated_date, uuid: @client_identifier.uuid, value: @client_identifier.value, voided: @client_identifier.voided, voided_by: @client_identifier.voided_by, voided_date: @client_identifier.voided_date, voided_reason: @client_identifier.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy client_identifier" do
    assert_difference('ClientIdentifier.count', -1) do
      delete api_v1_client_identifier_url(@client_identifier), as: :json
    end

    assert_response 204
  end
end
