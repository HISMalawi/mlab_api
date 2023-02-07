require 'test_helper'

class Api::V1::EncountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @encounter = encounters(:one)
  end

  test "should get index" do
    get api_v1_encounters_url, as: :json
    assert_response :success
  end

  test "should create encounter" do
    assert_difference('Encounter.count') do
      post api_v1_encounters_url, params: { encounter: { client_id: @encounter.client_id, created_date: @encounter.created_date, creator: @encounter.creator, destination_id: @encounter.destination_id, end_date: @encounter.end_date, facility_id: @encounter.facility_id, facility_section_id: @encounter.facility_section_id, start_date: @encounter.start_date, updated_date: @encounter.updated_date, uuid: @encounter.uuid, voided: @encounter.voided, voided_by: @encounter.voided_by, voided_date: @encounter.voided_date, voided_reason: @encounter.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show encounter" do
    get api_v1_encounter_url(@encounter), as: :json
    assert_response :success
  end

  test "should update encounter" do
    patch api_v1_encounter_url(@encounter), params: { encounter: { client_id: @encounter.client_id, created_date: @encounter.created_date, creator: @encounter.creator, destination_id: @encounter.destination_id, end_date: @encounter.end_date, facility_id: @encounter.facility_id, facility_section_id: @encounter.facility_section_id, start_date: @encounter.start_date, updated_date: @encounter.updated_date, uuid: @encounter.uuid, voided: @encounter.voided, voided_by: @encounter.voided_by, voided_date: @encounter.voided_date, voided_reason: @encounter.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy encounter" do
    assert_difference('Encounter.count', -1) do
      delete api_v1_encounter_url(@encounter), as: :json
    end

    assert_response 204
  end
end
