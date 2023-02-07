require 'test_helper'

class Api::V1::TestPanelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_panel = test_panels(:one)
  end

  test "should get index" do
    get api_v1_test_panels_url, as: :json
    assert_response :success
  end

  test "should create test_panel" do
    assert_difference('TestPanel.count') do
      post api_v1_test_panels_url, params: { test_panel: { created_date: @test_panel.created_date, creator: @test_panel.creator, description: @test_panel.description, name: @test_panel.name, retired: @test_panel.retired, retired_by: @test_panel.retired_by, retired_date: @test_panel.retired_date, retired_reason: @test_panel.retired_reason, updated_date: @test_panel.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show test_panel" do
    get api_v1_test_panel_url(@test_panel), as: :json
    assert_response :success
  end

  test "should update test_panel" do
    patch api_v1_test_panel_url(@test_panel), params: { test_panel: { created_date: @test_panel.created_date, creator: @test_panel.creator, description: @test_panel.description, name: @test_panel.name, retired: @test_panel.retired, retired_by: @test_panel.retired_by, retired_date: @test_panel.retired_date, retired_reason: @test_panel.retired_reason, updated_date: @test_panel.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy test_panel" do
    assert_difference('TestPanel.count', -1) do
      delete api_v1_test_panel_url(@test_panel), as: :json
    end

    assert_response 204
  end
end
