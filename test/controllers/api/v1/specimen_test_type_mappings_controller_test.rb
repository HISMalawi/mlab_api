require 'test_helper'

class Api::V1::SpecimenTestTypeMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @specimen_test_type_mapping = specimen_test_type_mappings(:one)
  end

  test "should get index" do
    get api_v1_specimen_test_type_mappings_url, as: :json
    assert_response :success
  end

  test "should create specimen_test_type_mapping" do
    assert_difference('SpecimenTestTypeMapping.count') do
      post api_v1_specimen_test_type_mappings_url, params: { specimen_test_type_mapping: { created_date: @specimen_test_type_mapping.created_date, creator: @specimen_test_type_mapping.creator, retired: @specimen_test_type_mapping.retired, retired_by: @specimen_test_type_mapping.retired_by, retired_date: @specimen_test_type_mapping.retired_date, retired_reason: @specimen_test_type_mapping.retired_reason, specimen_id: @specimen_test_type_mapping.specimen_id, test_type_id: @specimen_test_type_mapping.test_type_id, updated_date: @specimen_test_type_mapping.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show specimen_test_type_mapping" do
    get api_v1_specimen_test_type_mapping_url(@specimen_test_type_mapping), as: :json
    assert_response :success
  end

  test "should update specimen_test_type_mapping" do
    patch api_v1_specimen_test_type_mapping_url(@specimen_test_type_mapping), params: { specimen_test_type_mapping: { created_date: @specimen_test_type_mapping.created_date, creator: @specimen_test_type_mapping.creator, retired: @specimen_test_type_mapping.retired, retired_by: @specimen_test_type_mapping.retired_by, retired_date: @specimen_test_type_mapping.retired_date, retired_reason: @specimen_test_type_mapping.retired_reason, specimen_id: @specimen_test_type_mapping.specimen_id, test_type_id: @specimen_test_type_mapping.test_type_id, updated_date: @specimen_test_type_mapping.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy specimen_test_type_mapping" do
    assert_difference('SpecimenTestTypeMapping.count', -1) do
      delete api_v1_specimen_test_type_mapping_url(@specimen_test_type_mapping), as: :json
    end

    assert_response 204
  end
end
