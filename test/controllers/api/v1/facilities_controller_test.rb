require 'test_helper'

class Api::V1::FacilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @facility = facilities(:one)
  end

  test "should get index" do
    get api_v1_facilities_url, as: :json
    assert_response :success
  end

  test "should create facility" do
    assert_difference('Facility.count') do
      post api_v1_facilities_url, params: { facility: { created_date: @facility.created_date, creator: @facility.creator, name: @facility.name, retired: @facility.retired, retired_by: @facility.retired_by, retired_date: @facility.retired_date, retired_reason: @facility.retired_reason, updated_date: @facility.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show facility" do
    get api_v1_facility_url(@facility), as: :json
    assert_response :success
  end

  test "should update facility" do
    patch api_v1_facility_url(@facility), params: { facility: { created_date: @facility.created_date, creator: @facility.creator, name: @facility.name, retired: @facility.retired, retired_by: @facility.retired_by, retired_date: @facility.retired_date, retired_reason: @facility.retired_reason, updated_date: @facility.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy facility" do
    assert_difference('Facility.count', -1) do
      delete api_v1_facility_url(@facility), as: :json
    end

    assert_response 204
  end
end
