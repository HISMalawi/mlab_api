require 'test_helper'

class Api::V1::TestIndicatorRangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_indicator_range = test_indicator_ranges(:one)
  end

  test "should get index" do
    get api_v1_test_indicator_ranges_url, as: :json
    assert_response :success
  end

  test "should create test_indicator_range" do
    assert_difference('TestIndicatorRange.count') do
      post api_v1_test_indicator_ranges_url, params: { test_indicator_range: { created_date: @test_indicator_range.created_date, creator: @test_indicator_range.creator, interpretation: @test_indicator_range.interpretation, lower_range: @test_indicator_range.lower_range, max_age: @test_indicator_range.max_age, min_age: @test_indicator_range.min_age, retired: @test_indicator_range.retired, retired_by: @test_indicator_range.retired_by, retired_date: @test_indicator_range.retired_date, retired_reason: @test_indicator_range.retired_reason, sex: @test_indicator_range.sex, test_indicator_id: @test_indicator_range.test_indicator_id, updated_date: @test_indicator_range.updated_date, upper_range: @test_indicator_range.upper_range, value: @test_indicator_range.value } }, as: :json
    end

    assert_response 201
  end

  test "should show test_indicator_range" do
    get api_v1_test_indicator_range_url(@test_indicator_range), as: :json
    assert_response :success
  end

  test "should update test_indicator_range" do
    patch api_v1_test_indicator_range_url(@test_indicator_range), params: { test_indicator_range: { created_date: @test_indicator_range.created_date, creator: @test_indicator_range.creator, interpretation: @test_indicator_range.interpretation, lower_range: @test_indicator_range.lower_range, max_age: @test_indicator_range.max_age, min_age: @test_indicator_range.min_age, retired: @test_indicator_range.retired, retired_by: @test_indicator_range.retired_by, retired_date: @test_indicator_range.retired_date, retired_reason: @test_indicator_range.retired_reason, sex: @test_indicator_range.sex, test_indicator_id: @test_indicator_range.test_indicator_id, updated_date: @test_indicator_range.updated_date, upper_range: @test_indicator_range.upper_range, value: @test_indicator_range.value } }, as: :json
    assert_response 200
  end

  test "should destroy test_indicator_range" do
    assert_difference('TestIndicatorRange.count', -1) do
      delete api_v1_test_indicator_range_url(@test_indicator_range), as: :json
    end

    assert_response 204
  end
end
