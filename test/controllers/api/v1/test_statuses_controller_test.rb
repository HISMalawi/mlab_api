require 'test_helper'

class Api::V1::TestStatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_status = test_statuses(:one)
  end

  test "should get index" do
    get api_v1_test_statuses_url, as: :json
    assert_response :success
  end

  test "should create test_status" do
    assert_difference('TestStatus.count') do
      post api_v1_test_statuses_url, params: { test_status: { creator: @test_status.creator, status_id: @test_status.status_id, status_reason_id: @test_status.status_reason_id, test_id: @test_status.test_id, voided: @test_status.voided, voided_by: @test_status.voided_by, voided_date: @test_status.voided_date, voided_reason: @test_status.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show test_status" do
    get api_v1_test_status_url(@test_status), as: :json
    assert_response :success
  end

  test "should update test_status" do
    patch api_v1_test_status_url(@test_status), params: { test_status: { creator: @test_status.creator, status_id: @test_status.status_id, status_reason_id: @test_status.status_reason_id, test_id: @test_status.test_id, voided: @test_status.voided, voided_by: @test_status.voided_by, voided_date: @test_status.voided_date, voided_reason: @test_status.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy test_status" do
    assert_difference('TestStatus.count', -1) do
      delete api_v1_test_status_url(@test_status), as: :json
    end

    assert_response 204
  end
end
