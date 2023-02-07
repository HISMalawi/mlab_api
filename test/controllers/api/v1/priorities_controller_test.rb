require 'test_helper'

class Api::V1::PrioritiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @priority = priorities(:one)
  end

  test "should get index" do
    get api_v1_priorities_url, as: :json
    assert_response :success
  end

  test "should create priority" do
    assert_difference('Priority.count') do
      post api_v1_priorities_url, params: { priority: { created_date: @priority.created_date, creator: @priority.creator, name: @priority.name, retired: @priority.retired, retired_by: @priority.retired_by, retired_date: @priority.retired_date, retired_reason: @priority.retired_reason, updated_date: @priority.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show priority" do
    get api_v1_priority_url(@priority), as: :json
    assert_response :success
  end

  test "should update priority" do
    patch api_v1_priority_url(@priority), params: { priority: { created_date: @priority.created_date, creator: @priority.creator, name: @priority.name, retired: @priority.retired, retired_by: @priority.retired_by, retired_date: @priority.retired_date, retired_reason: @priority.retired_reason, updated_date: @priority.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy priority" do
    assert_difference('Priority.count', -1) do
      delete api_v1_priority_url(@priority), as: :json
    end

    assert_response 204
  end
end
