require 'test_helper'

class Api::V1::StatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = statuses(:one)
  end

  test "should get index" do
    get api_v1_statuses_url, as: :json
    assert_response :success
  end

  test "should create status" do
    assert_difference('Status.count') do
      post api_v1_statuses_url, params: { status: { creator: @status.creator, name: @status.name, retired: @status.retired, retired_by: @status.retired_by, retired_date: @status.retired_date, retired_reason: @status.retired_reason, updated_date: @status.updated_date, updated_date_copy1: @status.updated_date_copy1 } }, as: :json
    end

    assert_response 201
  end

  test "should show status" do
    get api_v1_status_url(@status), as: :json
    assert_response :success
  end

  test "should update status" do
    patch api_v1_status_url(@status), params: { status: { creator: @status.creator, name: @status.name, retired: @status.retired, retired_by: @status.retired_by, retired_date: @status.retired_date, retired_reason: @status.retired_reason, updated_date: @status.updated_date, updated_date_copy1: @status.updated_date_copy1 } }, as: :json
    assert_response 200
  end

  test "should destroy status" do
    assert_difference('Status.count', -1) do
      delete api_v1_status_url(@status), as: :json
    end

    assert_response 204
  end
end
