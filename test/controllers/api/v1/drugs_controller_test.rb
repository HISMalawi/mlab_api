require 'test_helper'

class Api::V1::DrugsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @drug = drugs(:one)
  end

  test "should get index" do
    get api_v1_drugs_url, as: :json
    assert_response :success
  end

  test "should create drug" do
    assert_difference('Drug.count') do
      post api_v1_drugs_url, params: { drug: { created_date: @drug.created_date, creator: @drug.creator, name: @drug.name, retired: @drug.retired, retired_by: @drug.retired_by, retired_date: @drug.retired_date, retired_reason: @drug.retired_reason, short_name: @drug.short_name, updated_date: @drug.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show drug" do
    get api_v1_drug_url(@drug), as: :json
    assert_response :success
  end

  test "should update drug" do
    patch api_v1_drug_url(@drug), params: { drug: { created_date: @drug.created_date, creator: @drug.creator, name: @drug.name, retired: @drug.retired, retired_by: @drug.retired_by, retired_date: @drug.retired_date, retired_reason: @drug.retired_reason, short_name: @drug.short_name, updated_date: @drug.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy drug" do
    assert_difference('Drug.count', -1) do
      delete api_v1_drug_url(@drug), as: :json
    end

    assert_response 204
  end
end
