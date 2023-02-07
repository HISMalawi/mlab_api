require 'test_helper'

class Api::V1::TestResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_result = test_results(:one)
  end

  test "should get index" do
    get api_v1_test_results_url, as: :json
    assert_response :success
  end

  test "should create test_result" do
    assert_difference('TestResult.count') do
      post api_v1_test_results_url, params: { test_result: { created_date: @test_result.created_date, creator: @test_result.creator, result_date: @test_result.result_date, test_id: @test_result.test_id, test_indicator_id: @test_result.test_indicator_id, updated_date: @test_result.updated_date, value: @test_result.value, voided: @test_result.voided, voided_by: @test_result.voided_by, voided_date: @test_result.voided_date, voided_reason: @test_result.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show test_result" do
    get api_v1_test_result_url(@test_result), as: :json
    assert_response :success
  end

  test "should update test_result" do
    patch api_v1_test_result_url(@test_result), params: { test_result: { created_date: @test_result.created_date, creator: @test_result.creator, result_date: @test_result.result_date, test_id: @test_result.test_id, test_indicator_id: @test_result.test_indicator_id, updated_date: @test_result.updated_date, value: @test_result.value, voided: @test_result.voided, voided_by: @test_result.voided_by, voided_date: @test_result.voided_date, voided_reason: @test_result.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy test_result" do
    assert_difference('TestResult.count', -1) do
      delete api_v1_test_result_url(@test_result), as: :json
    end

    assert_response 204
  end
end
