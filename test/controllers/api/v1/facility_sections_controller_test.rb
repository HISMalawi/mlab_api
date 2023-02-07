require 'test_helper'

class Api::V1::FacilitySectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @facility_section = facility_sections(:one)
  end

  test "should get index" do
    get api_v1_facility_sections_url, as: :json
    assert_response :success
  end

  test "should create facility_section" do
    assert_difference('FacilitySection.count') do
      post api_v1_facility_sections_url, params: { facility_section: { created_date: @facility_section.created_date, creator: @facility_section.creator, name: @facility_section.name, retired: @facility_section.retired, retired_by: @facility_section.retired_by, retired_date: @facility_section.retired_date, retired_reason: @facility_section.retired_reason, updated_date: @facility_section.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show facility_section" do
    get api_v1_facility_section_url(@facility_section), as: :json
    assert_response :success
  end

  test "should update facility_section" do
    patch api_v1_facility_section_url(@facility_section), params: { facility_section: { created_date: @facility_section.created_date, creator: @facility_section.creator, name: @facility_section.name, retired: @facility_section.retired, retired_by: @facility_section.retired_by, retired_date: @facility_section.retired_date, retired_reason: @facility_section.retired_reason, updated_date: @facility_section.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy facility_section" do
    assert_difference('FacilitySection.count', -1) do
      delete api_v1_facility_section_url(@facility_section), as: :json
    end

    assert_response 204
  end
end
