require 'test_helper'

class Api::V1::SpecimenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @speciman = specimen(:one)
  end

  test "should get index" do
    get api_v1_specimen_index_url, as: :json
    assert_response :success
  end

  test "should create speciman" do
    assert_difference('Specimen.count') do
      post api_v1_specimen_index_url, params: { speciman: { created_date: @speciman.created_date, creator: @speciman.creator, name: @speciman.name, retired: @speciman.retired, retired_by: @speciman.retired_by, retired_date: @speciman.retired_date, retired_reason: @speciman.retired_reason, updated_date: @speciman.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show speciman" do
    get api_v1_speciman_url(@speciman), as: :json
    assert_response :success
  end

  test "should update speciman" do
    patch api_v1_speciman_url(@speciman), params: { speciman: { created_date: @speciman.created_date, creator: @speciman.creator, name: @speciman.name, retired: @speciman.retired, retired_by: @speciman.retired_by, retired_date: @speciman.retired_date, retired_reason: @speciman.retired_reason, updated_date: @speciman.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy speciman" do
    assert_difference('Specimen.count', -1) do
      delete api_v1_speciman_url(@speciman), as: :json
    end

    assert_response 204
  end
end
