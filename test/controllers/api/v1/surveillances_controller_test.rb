require "test_helper"

class Api::V1::SurveillancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_surveillance = api_v1_surveillances(:one)
  end

  test "should get index" do
    get api_v1_surveillances_url, as: :json
    assert_response :success
  end

  test "should create api_v1_surveillance" do
    assert_difference("Api::V1::Surveillance.count") do
      post api_v1_surveillances_url, params: { api_v1_surveillance: {  } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_surveillance" do
    get api_v1_surveillance_url(@api_v1_surveillance), as: :json
    assert_response :success
  end

  test "should update api_v1_surveillance" do
    patch api_v1_surveillance_url(@api_v1_surveillance), params: { api_v1_surveillance: {  } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_surveillance" do
    assert_difference("Api::V1::Surveillance.count", -1) do
      delete api_v1_surveillance_url(@api_v1_surveillance), as: :json
    end

    assert_response :no_content
  end
end
