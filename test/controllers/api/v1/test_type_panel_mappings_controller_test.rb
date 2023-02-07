require 'test_helper'

class Api::V1::TestTypePanelMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_type_panel_mapping = test_type_panel_mappings(:one)
  end

  test "should get index" do
    get api_v1_test_type_panel_mappings_url, as: :json
    assert_response :success
  end

  test "should create test_type_panel_mapping" do
    assert_difference('TestTypePanelMapping.count') do
      post api_v1_test_type_panel_mappings_url, params: { test_type_panel_mapping: { created_date: @test_type_panel_mapping.created_date, creator: @test_type_panel_mapping.creator, test_panel_id: @test_type_panel_mapping.test_panel_id, test_type_id: @test_type_panel_mapping.test_type_id, updated_date: @test_type_panel_mapping.updated_date, voided: @test_type_panel_mapping.voided, voided_by: @test_type_panel_mapping.voided_by, voided_date: @test_type_panel_mapping.voided_date, voided_reason: @test_type_panel_mapping.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show test_type_panel_mapping" do
    get api_v1_test_type_panel_mapping_url(@test_type_panel_mapping), as: :json
    assert_response :success
  end

  test "should update test_type_panel_mapping" do
    patch api_v1_test_type_panel_mapping_url(@test_type_panel_mapping), params: { test_type_panel_mapping: { created_date: @test_type_panel_mapping.created_date, creator: @test_type_panel_mapping.creator, test_panel_id: @test_type_panel_mapping.test_panel_id, test_type_id: @test_type_panel_mapping.test_type_id, updated_date: @test_type_panel_mapping.updated_date, voided: @test_type_panel_mapping.voided, voided_by: @test_type_panel_mapping.voided_by, voided_date: @test_type_panel_mapping.voided_date, voided_reason: @test_type_panel_mapping.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy test_type_panel_mapping" do
    assert_difference('TestTypePanelMapping.count', -1) do
      delete api_v1_test_type_panel_mapping_url(@test_type_panel_mapping), as: :json
    end

    assert_response 204
  end
end
