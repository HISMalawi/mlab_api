require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get api_v1_users_url, as: :json
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post api_v1_users_url, params: { user: { created_date: @user.created_date, creator: @user.creator, last_password_changed: @user.last_password_changed, password: @user.password, person_id: @user.person_id, role_id: @user.role_id, updated_date: @user.updated_date, username: @user.username, voided: @user.voided, voided_by: @user.voided_by, voided_date: @user.voided_date, voided_reason: @user.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show user" do
    get api_v1_user_url(@user), as: :json
    assert_response :success
  end

  test "should update user" do
    patch api_v1_user_url(@user), params: { user: { created_date: @user.created_date, creator: @user.creator, last_password_changed: @user.last_password_changed, password: @user.password, person_id: @user.person_id, role_id: @user.role_id, updated_date: @user.updated_date, username: @user.username, voided: @user.voided, voided_by: @user.voided_by, voided_date: @user.voided_date, voided_reason: @user.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete api_v1_user_url(@user), as: :json
    end

    assert_response 204
  end
end
