require 'test_helper'

class Api::V1::PrivilegesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @privilege = privileges(:one)
  end

  test "should get index" do
    get api_v1_privileges_url, as: :json
    assert_response :success
  end

  test "should create privilege" do
    assert_difference('Privilege.count') do
      post api_v1_privileges_url, params: { privilege: { created_date: @privilege.created_date, creator: @privilege.creator, name: @privilege.name, retired: @privilege.retired, retired_by: @privilege.retired_by, retired_date: @privilege.retired_date, retired_reason: @privilege.retired_reason, updated_date: @privilege.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show privilege" do
    get api_v1_privilege_url(@privilege), as: :json
    assert_response :success
  end

  test "should update privilege" do
    patch api_v1_privilege_url(@privilege), params: { privilege: { created_date: @privilege.created_date, creator: @privilege.creator, name: @privilege.name, retired: @privilege.retired, retired_by: @privilege.retired_by, retired_date: @privilege.retired_date, retired_reason: @privilege.retired_reason, updated_date: @privilege.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy privilege" do
    assert_difference('Privilege.count', -1) do
      delete api_v1_privilege_url(@privilege), as: :json
    end

    assert_response 204
  end
end
