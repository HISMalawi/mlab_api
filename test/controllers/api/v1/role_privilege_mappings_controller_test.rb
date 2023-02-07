require 'test_helper'

class Api::V1::RolePrivilegeMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @role_privilege_mapping = role_privilege_mappings(:one)
  end

  test "should get index" do
    get api_v1_role_privilege_mappings_url, as: :json
    assert_response :success
  end

  test "should create role_privilege_mapping" do
    assert_difference('RolePrivilegeMapping.count') do
      post api_v1_role_privilege_mappings_url, params: { role_privilege_mapping: { created_date: @role_privilege_mapping.created_date, creator: @role_privilege_mapping.creator, privilege_id: @role_privilege_mapping.privilege_id, role_id: @role_privilege_mapping.role_id, updated_date: @role_privilege_mapping.updated_date, voided: @role_privilege_mapping.voided, voided_by: @role_privilege_mapping.voided_by, voided_date: @role_privilege_mapping.voided_date, voided_reason: @role_privilege_mapping.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show role_privilege_mapping" do
    get api_v1_role_privilege_mapping_url(@role_privilege_mapping), as: :json
    assert_response :success
  end

  test "should update role_privilege_mapping" do
    patch api_v1_role_privilege_mapping_url(@role_privilege_mapping), params: { role_privilege_mapping: { created_date: @role_privilege_mapping.created_date, creator: @role_privilege_mapping.creator, privilege_id: @role_privilege_mapping.privilege_id, role_id: @role_privilege_mapping.role_id, updated_date: @role_privilege_mapping.updated_date, voided: @role_privilege_mapping.voided, voided_by: @role_privilege_mapping.voided_by, voided_date: @role_privilege_mapping.voided_date, voided_reason: @role_privilege_mapping.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy role_privilege_mapping" do
    assert_difference('RolePrivilegeMapping.count', -1) do
      delete api_v1_role_privilege_mapping_url(@role_privilege_mapping), as: :json
    end

    assert_response 204
  end
end
