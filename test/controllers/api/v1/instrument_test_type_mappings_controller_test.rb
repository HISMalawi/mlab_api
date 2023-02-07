require 'test_helper'

class Api::V1::InstrumentTestTypeMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @instrument_test_type_mapping = instrument_test_type_mappings(:one)
  end

  test "should get index" do
    get api_v1_instrument_test_type_mappings_url, as: :json
    assert_response :success
  end

  test "should create instrument_test_type_mapping" do
    assert_difference('InstrumentTestTypeMapping.count') do
      post api_v1_instrument_test_type_mappings_url, params: { instrument_test_type_mapping: { created_date: @instrument_test_type_mapping.created_date, creator: @instrument_test_type_mapping.creator, instrument_id: @instrument_test_type_mapping.instrument_id, retired: @instrument_test_type_mapping.retired, retired_by: @instrument_test_type_mapping.retired_by, retired_date: @instrument_test_type_mapping.retired_date, retired_reason: @instrument_test_type_mapping.retired_reason, test_type_id: @instrument_test_type_mapping.test_type_id, updated_date: @instrument_test_type_mapping.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show instrument_test_type_mapping" do
    get api_v1_instrument_test_type_mapping_url(@instrument_test_type_mapping), as: :json
    assert_response :success
  end

  test "should update instrument_test_type_mapping" do
    patch api_v1_instrument_test_type_mapping_url(@instrument_test_type_mapping), params: { instrument_test_type_mapping: { created_date: @instrument_test_type_mapping.created_date, creator: @instrument_test_type_mapping.creator, instrument_id: @instrument_test_type_mapping.instrument_id, retired: @instrument_test_type_mapping.retired, retired_by: @instrument_test_type_mapping.retired_by, retired_date: @instrument_test_type_mapping.retired_date, retired_reason: @instrument_test_type_mapping.retired_reason, test_type_id: @instrument_test_type_mapping.test_type_id, updated_date: @instrument_test_type_mapping.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy instrument_test_type_mapping" do
    assert_difference('InstrumentTestTypeMapping.count', -1) do
      delete api_v1_instrument_test_type_mapping_url(@instrument_test_type_mapping), as: :json
    end

    assert_response 204
  end
end
