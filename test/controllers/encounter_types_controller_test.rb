require "test_helper"

class EncounterTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @encounter_type = encounter_types(:one)
  end

  test "should get index" do
    get encounter_types_url, as: :json
    assert_response :success
  end

  test "should create encounter_type" do
    assert_difference("EncounterType.count") do
      post encounter_types_url, params: { encounter_type: { name: @encounter_type.name } }, as: :json
    end

    assert_response :created
  end

  test "should show encounter_type" do
    get encounter_type_url(@encounter_type), as: :json
    assert_response :success
  end

  test "should update encounter_type" do
    patch encounter_type_url(@encounter_type), params: { encounter_type: { name: @encounter_type.name } }, as: :json
    assert_response :success
  end

  test "should destroy encounter_type" do
    assert_difference("EncounterType.count", -1) do
      delete encounter_type_url(@encounter_type), as: :json
    end

    assert_response :no_content
  end
end
