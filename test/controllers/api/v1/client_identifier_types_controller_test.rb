require 'test_helper'

class Api::V1::ClientIdentifierTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client_identifier_type = client_identifier_types(:one)
  end

  test "should get index" do
    get api_v1_client_identifier_types_url, as: :json
    assert_response :success
  end

  test "should create client_identifier_type" do
    assert_difference('ClientIdentifierType.count') do
      post api_v1_client_identifier_types_url, params: { client_identifier_type: { created_date: @client_identifier_type.created_date, creator: @client_identifier_type.creator, name: @client_identifier_type.name, retired: @client_identifier_type.retired, retired_by: @client_identifier_type.retired_by, retired_date: @client_identifier_type.retired_date, retired_reason: @client_identifier_type.retired_reason, updated_date: @client_identifier_type.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show client_identifier_type" do
    get api_v1_client_identifier_type_url(@client_identifier_type), as: :json
    assert_response :success
  end

  test "should update client_identifier_type" do
    patch api_v1_client_identifier_type_url(@client_identifier_type), params: { client_identifier_type: { created_date: @client_identifier_type.created_date, creator: @client_identifier_type.creator, name: @client_identifier_type.name, retired: @client_identifier_type.retired, retired_by: @client_identifier_type.retired_by, retired_date: @client_identifier_type.retired_date, retired_reason: @client_identifier_type.retired_reason, updated_date: @client_identifier_type.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy client_identifier_type" do
    assert_difference('ClientIdentifierType.count', -1) do
      delete api_v1_client_identifier_type_url(@client_identifier_type), as: :json
    end

    assert_response 204
  end
end
