require 'test_helper'

class Api::V1::StatusReasonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status_reason = status_reasons(:one)
  end

  test "should get index" do
    get api_v1_status_reasons_url, as: :json
    assert_response :success
  end

  test "should create status_reason" do
    assert_difference('StatusReason.count') do
      post api_v1_status_reasons_url, params: { status_reason: { created_date: @status_reason.created_date, creator: @status_reason.creator, description: @status_reason.description, retired: @status_reason.retired, retired_by: @status_reason.retired_by, retired_date: @status_reason.retired_date, retired_reason: @status_reason.retired_reason, updated_date: @status_reason.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show status_reason" do
    get api_v1_status_reason_url(@status_reason), as: :json
    assert_response :success
  end

  test "should update status_reason" do
    patch api_v1_status_reason_url(@status_reason), params: { status_reason: { created_date: @status_reason.created_date, creator: @status_reason.creator, description: @status_reason.description, retired: @status_reason.retired, retired_by: @status_reason.retired_by, retired_date: @status_reason.retired_date, retired_reason: @status_reason.retired_reason, updated_date: @status_reason.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy status_reason" do
    assert_difference('StatusReason.count', -1) do
      delete api_v1_status_reason_url(@status_reason), as: :json
    end

    assert_response 204
  end
end
