require 'test_helper'

class Api::V1::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @department = departments(:one)
  end

  test "should get index" do
    get api_v1_departments_url, as: :json
    assert_response :success
  end

  test "should create department" do
    assert_difference('Department.count') do
      post api_v1_departments_url, params: { department: { created_date: @department.created_date, creator: @department.creator, name: @department.name, retired: @department.retired, retired_by: @department.retired_by, retired_date: @department.retired_date, retired_reason: @department.retired_reason, updated_date: @department.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show department" do
    get api_v1_department_url(@department), as: :json
    assert_response :success
  end

  test "should update department" do
    patch api_v1_department_url(@department), params: { department: { created_date: @department.created_date, creator: @department.creator, name: @department.name, retired: @department.retired, retired_by: @department.retired_by, retired_date: @department.retired_date, retired_reason: @department.retired_reason, updated_date: @department.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy department" do
    assert_difference('Department.count', -1) do
      delete api_v1_department_url(@department), as: :json
    end

    assert_response 204
  end
end
