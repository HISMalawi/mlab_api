require 'test_helper'

class Api::V1::TestIndicatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_indicator = test_indicators(:one)
  end

  test "should get index" do
    get api_v1_test_indicators_url, as: :json
    assert_response :success
  end

  test "should create test_indicator" do
    assert_difference('TestIndicator.count') do
      post api_v1_test_indicators_url, params: { test_indicator: { created_date: @test_indicator.created_date, creator: @test_indicator.creator, description: @test_indicator.description, name: @test_indicator.name, retired: @test_indicator.retired, retired_by: @test_indicator.retired_by, retired_date: @test_indicator.retired_date, retired_reason: @test_indicator.retired_reason, test_indicator_type: @test_indicator.test_indicator_type, test_type_id: @test_indicator.test_type_id, unit: @test_indicator.unit, updated_date: @test_indicator.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show test_indicator" do
    get api_v1_test_indicator_url(@test_indicator), as: :json
    assert_response :success
  end

  test "should update test_indicator" do
    patch api_v1_test_indicator_url(@test_indicator), params: { test_indicator: { created_date: @test_indicator.created_date, creator: @test_indicator.creator, description: @test_indicator.description, name: @test_indicator.name, retired: @test_indicator.retired, retired_by: @test_indicator.retired_by, retired_date: @test_indicator.retired_date, retired_reason: @test_indicator.retired_reason, test_indicator_type: @test_indicator.test_indicator_type, test_type_id: @test_indicator.test_type_id, unit: @test_indicator.unit, updated_date: @test_indicator.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy test_indicator" do
    assert_difference('TestIndicator.count', -1) do
      delete api_v1_test_indicator_url(@test_indicator), as: :json
    end

    assert_response 204
  end
end
