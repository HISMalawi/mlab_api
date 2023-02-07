require 'test_helper'

class Api::V1::InstrumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @instrument = instruments(:one)
  end

  test "should get index" do
    get api_v1_instruments_url, as: :json
    assert_response :success
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post api_v1_instruments_url, params: { instrument: { created_date: @instrument.created_date, creator: @instrument.creator, description: @instrument.description, hostname: @instrument.hostname, ip_address: @instrument.ip_address, name: @instrument.name, retired: @instrument.retired, retired_by: @instrument.retired_by, retired_date: @instrument.retired_date, retired_reason: @instrument.retired_reason, updated_date: @instrument.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show instrument" do
    get api_v1_instrument_url(@instrument), as: :json
    assert_response :success
  end

  test "should update instrument" do
    patch api_v1_instrument_url(@instrument), params: { instrument: { created_date: @instrument.created_date, creator: @instrument.creator, description: @instrument.description, hostname: @instrument.hostname, ip_address: @instrument.ip_address, name: @instrument.name, retired: @instrument.retired, retired_by: @instrument.retired_by, retired_date: @instrument.retired_date, retired_reason: @instrument.retired_reason, updated_date: @instrument.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy instrument" do
    assert_difference('Instrument.count', -1) do
      delete api_v1_instrument_url(@instrument), as: :json
    end

    assert_response 204
  end
end
