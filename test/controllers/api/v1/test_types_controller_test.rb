require 'test_helper'

class Api::V1::TestTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_type = test_types(:one)
  end

  test "should get index" do
    get api_v1_test_types_url, as: :json
    assert_response :success
  end

  test "should create test_type" do
    assert_difference('TestType.count') do
      post api_v1_test_types_url, params: { test_type: { created_date: @test_type.created_date, creator: @test_type.creator, department_id: @test_type.department_id, expected_turn_around_time: @test_type.expected_turn_around_time, name: @test_type.name, retired: @test_type.retired, retired_by: @test_type.retired_by, retired_date: @test_type.retired_date, retired_reason: @test_type.retired_reason, updated_date: @test_type.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show test_type" do
    get api_v1_test_type_url(@test_type), as: :json
    assert_response :success
  end

  test "should update test_type" do
    patch api_v1_test_type_url(@test_type), params: { test_type: { created_date: @test_type.created_date, creator: @test_type.creator, department_id: @test_type.department_id, expected_turn_around_time: @test_type.expected_turn_around_time, name: @test_type.name, retired: @test_type.retired, retired_by: @test_type.retired_by, retired_date: @test_type.retired_date, retired_reason: @test_type.retired_reason, updated_date: @test_type.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy test_type" do
    assert_difference('TestType.count', -1) do
      delete api_v1_test_type_url(@test_type), as: :json
    end

    assert_response 204
  end
end
