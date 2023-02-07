require 'test_helper'

class Api::V1::OrganismsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organism = organisms(:one)
  end

  test "should get index" do
    get api_v1_organisms_url, as: :json
    assert_response :success
  end

  test "should create organism" do
    assert_difference('Organism.count') do
      post api_v1_organisms_url, params: { organism: { created_date: @organism.created_date, creator: @organism.creator, description: @organism.description, name: @organism.name, retired: @organism.retired, retired_by: @organism.retired_by, retired_date: @organism.retired_date, retired_reason: @organism.retired_reason, updated_date: @organism.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show organism" do
    get api_v1_organism_url(@organism), as: :json
    assert_response :success
  end

  test "should update organism" do
    patch api_v1_organism_url(@organism), params: { organism: { created_date: @organism.created_date, creator: @organism.creator, description: @organism.description, name: @organism.name, retired: @organism.retired, retired_by: @organism.retired_by, retired_date: @organism.retired_date, retired_reason: @organism.retired_reason, updated_date: @organism.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy organism" do
    assert_difference('Organism.count', -1) do
      delete api_v1_organism_url(@organism), as: :json
    end

    assert_response 204
  end
end
