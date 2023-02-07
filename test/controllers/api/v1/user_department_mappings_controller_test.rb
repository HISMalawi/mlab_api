require 'test_helper'

class Api::V1::UserDepartmentMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_department_mapping = user_department_mappings(:one)
  end

  test "should get index" do
    get api_v1_user_department_mappings_url, as: :json
    assert_response :success
  end

  test "should create user_department_mapping" do
    assert_difference('UserDepartmentMapping.count') do
      post api_v1_user_department_mappings_url, params: { user_department_mapping: { created_date: @user_department_mapping.created_date, creator: @user_department_mapping.creator, department_id: @user_department_mapping.department_id, retired: @user_department_mapping.retired, retired_by: @user_department_mapping.retired_by, retired_date: @user_department_mapping.retired_date, retired_reason: @user_department_mapping.retired_reason, updated_date: @user_department_mapping.updated_date, user_id: @user_department_mapping.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show user_department_mapping" do
    get api_v1_user_department_mapping_url(@user_department_mapping), as: :json
    assert_response :success
  end

  test "should update user_department_mapping" do
    patch api_v1_user_department_mapping_url(@user_department_mapping), params: { user_department_mapping: { created_date: @user_department_mapping.created_date, creator: @user_department_mapping.creator, department_id: @user_department_mapping.department_id, retired: @user_department_mapping.retired, retired_by: @user_department_mapping.retired_by, retired_date: @user_department_mapping.retired_date, retired_reason: @user_department_mapping.retired_reason, updated_date: @user_department_mapping.updated_date, user_id: @user_department_mapping.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy user_department_mapping" do
    assert_difference('UserDepartmentMapping.count', -1) do
      delete api_v1_user_department_mapping_url(@user_department_mapping), as: :json
    end

    assert_response 204
  end
end
