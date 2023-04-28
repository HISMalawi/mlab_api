require "test_helper"

class Api::V1::DiseasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_disease = api_v1_diseases(:one)
  end

  test "should get index" do
    get api_v1_diseases, as: :json
    assert_response :success
  end

  test "should create api_v1_disease" do
    assert_difference("Disease.count") do
      post api_v1_diseases, params: { api_v1_disease: {  
        name: @api_v1_disease.name
      } }, as: :json
    end

    assert_response :created
  end

  test "should show api_v1_disease" do
    get api_v1_disease(@api_v1_disease), as: :json
    assert_response :success
  end

  test "should update api_v1_disease" do
    patch api_v1_disease(@api_v1_disease), params: { api_v1_disease: {  } }, as: :json
    assert_response :success
  end

  test "should destroy api_v1_disease" do
    assert_difference("Disease.count", -1) do
      delete api_v1_disease(@api_v1_disease), as: :json
    end

    assert_response :no_content
  end
end
