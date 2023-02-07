require 'test_helper'

class Api::V1::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get api_v1_orders_url, as: :json
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post api_v1_orders_url, params: { order: { accession_number: @order.accession_number, collected_by: @order.collected_by, creator: @order.creator, encounter_id: @order.encounter_id, priority_id: @order.priority_id, requested_by: @order.requested_by, sample_collected_time: @order.sample_collected_time, tracking_number: @order.tracking_number, voided: @order.voided, voided_by: @order.voided_by, voided_date: @order.voided_date, voided_reason: @order.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show order" do
    get api_v1_order_url(@order), as: :json
    assert_response :success
  end

  test "should update order" do
    patch api_v1_order_url(@order), params: { order: { accession_number: @order.accession_number, collected_by: @order.collected_by, creator: @order.creator, encounter_id: @order.encounter_id, priority_id: @order.priority_id, requested_by: @order.requested_by, sample_collected_time: @order.sample_collected_time, tracking_number: @order.tracking_number, voided: @order.voided, voided_by: @order.voided_by, voided_date: @order.voided_date, voided_reason: @order.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete api_v1_order_url(@order), as: :json
    end

    assert_response 204
  end
end
