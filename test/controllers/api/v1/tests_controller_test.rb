require 'test_helper'

class Api::V1::TestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test = tests(:one)
  end

  test "should get index" do
    get api_v1_tests_url, as: :json
    assert_response :success
  end

  test "should create test" do
    assert_difference('Test.count') do
      post api_v1_tests_url, params: { test: { created_date: @test.created_date, creator: @test.creator, order_id: @test.order_id, specimen_id: @test.specimen_id, test_type_id: @test.test_type_id, updated_date: @test.updated_date, voided: @test.voided, voided_by: @test.voided_by, voided_date: @test.voided_date, voided_reason: @test.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show test" do
    get api_v1_test_url(@test), as: :json
    assert_response :success
  end

  test "should update test" do
    patch api_v1_test_url(@test), params: { test: { created_date: @test.created_date, creator: @test.creator, order_id: @test.order_id, specimen_id: @test.specimen_id, test_type_id: @test.test_type_id, updated_date: @test.updated_date, voided: @test.voided, voided_by: @test.voided_by, voided_date: @test.voided_date, voided_reason: @test.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy test" do
    assert_difference('Test.count', -1) do
      delete api_v1_test_url(@test), as: :json
    end

    assert_response 204
  end
end
