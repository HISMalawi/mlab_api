require 'test_helper'

class Api::V1::UserRoleMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_role_mapping = user_role_mappings(:one)
  end

  test "should get index" do
    get api_v1_user_role_mappings_url, as: :json
    assert_response :success
  end

  test "should create user_role_mapping" do
    assert_difference('UserRoleMapping.count') do
      post api_v1_user_role_mappings_url, params: { user_role_mapping: { created_date: @user_role_mapping.created_date, creator: @user_role_mapping.creator, retired: @user_role_mapping.retired, retired_by: @user_role_mapping.retired_by, retired_date: @user_role_mapping.retired_date, retired_reason: @user_role_mapping.retired_reason, role_id: @user_role_mapping.role_id, updated_date: @user_role_mapping.updated_date, user_id: @user_role_mapping.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show user_role_mapping" do
    get api_v1_user_role_mapping_url(@user_role_mapping), as: :json
    assert_response :success
  end

  test "should update user_role_mapping" do
    patch api_v1_user_role_mapping_url(@user_role_mapping), params: { user_role_mapping: { created_date: @user_role_mapping.created_date, creator: @user_role_mapping.creator, retired: @user_role_mapping.retired, retired_by: @user_role_mapping.retired_by, retired_date: @user_role_mapping.retired_date, retired_reason: @user_role_mapping.retired_reason, role_id: @user_role_mapping.role_id, updated_date: @user_role_mapping.updated_date, user_id: @user_role_mapping.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy user_role_mapping" do
    assert_difference('UserRoleMapping.count', -1) do
      delete api_v1_user_role_mapping_url(@user_role_mapping), as: :json
    end

    assert_response 204
  end
end
