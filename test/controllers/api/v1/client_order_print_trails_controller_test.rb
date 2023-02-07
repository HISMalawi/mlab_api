require 'test_helper'

class Api::V1::ClientOrderPrintTrailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client_order_print_trail = client_order_print_trails(:one)
  end

  test "should get index" do
    get api_v1_client_order_print_trails_url, as: :json
    assert_response :success
  end

  test "should create client_order_print_trail" do
    assert_difference('ClientOrderPrintTrail.count') do
      post api_v1_client_order_print_trails_url, params: { client_order_print_trail: { creator: @client_order_print_trail.creator, order_id: @client_order_print_trail.order_id, voided: @client_order_print_trail.voided, voided_by: @client_order_print_trail.voided_by, voided_date: @client_order_print_trail.voided_date, voided_reason: @client_order_print_trail.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show client_order_print_trail" do
    get api_v1_client_order_print_trail_url(@client_order_print_trail), as: :json
    assert_response :success
  end

  test "should update client_order_print_trail" do
    patch api_v1_client_order_print_trail_url(@client_order_print_trail), params: { client_order_print_trail: { creator: @client_order_print_trail.creator, order_id: @client_order_print_trail.order_id, voided: @client_order_print_trail.voided, voided_by: @client_order_print_trail.voided_by, voided_date: @client_order_print_trail.voided_date, voided_reason: @client_order_print_trail.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy client_order_print_trail" do
    assert_difference('ClientOrderPrintTrail.count', -1) do
      delete api_v1_client_order_print_trail_url(@client_order_print_trail), as: :json
    end

    assert_response 204
  end
end
