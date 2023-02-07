require 'test_helper'

class Api::V1::CultureObservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @culture_observation = culture_observations(:one)
  end

  test "should get index" do
    get api_v1_culture_observations_url, as: :json
    assert_response :success
  end

  test "should create culture_observation" do
    assert_difference('CultureObservation.count') do
      post api_v1_culture_observations_url, params: { culture_observation: { created_date: @culture_observation.created_date, creator: @culture_observation.creator, description: @culture_observation.description, observation_datetime: @culture_observation.observation_datetime, test_id: @culture_observation.test_id, updated_date: @culture_observation.updated_date, voided: @culture_observation.voided, voided_by: @culture_observation.voided_by, voided_date: @culture_observation.voided_date, voided_reason: @culture_observation.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show culture_observation" do
    get api_v1_culture_observation_url(@culture_observation), as: :json
    assert_response :success
  end

  test "should update culture_observation" do
    patch api_v1_culture_observation_url(@culture_observation), params: { culture_observation: { created_date: @culture_observation.created_date, creator: @culture_observation.creator, description: @culture_observation.description, observation_datetime: @culture_observation.observation_datetime, test_id: @culture_observation.test_id, updated_date: @culture_observation.updated_date, voided: @culture_observation.voided, voided_by: @culture_observation.voided_by, voided_date: @culture_observation.voided_date, voided_reason: @culture_observation.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy culture_observation" do
    assert_difference('CultureObservation.count', -1) do
      delete api_v1_culture_observation_url(@culture_observation), as: :json
    end

    assert_response 204
  end
end
