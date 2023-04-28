class Api::V1::TestResultsController < ApplicationController
  def index
    render json: TestResult.all
  end
  
  def show
    render json: TestResult.find(params[:id])
  end

  def create
    permitted = test_result_params
    indicators = permitted[:test_indicators]
    unless permitted.has_key?(:test_id) && permitted.has_key?(:test_indicators)
      render json: {message: MessageService::MISSING_REQUIRED_PARAMETERS}, status: :bad_request and return
    end
    results = []
    ActiveRecord::Base.transaction do
      results = indicators.collect do |indicator_obj|
        indicator = indicator_obj[:indicator]
        value = indicator_obj[:value]
        unless TestIndicator.find_by_id(indicator).present?
          render json: {message: "Indicator with id #{indicator} not does not exists"} and return
        end
        TestResult.create!(test_id: permitted[:test_id], test_indicator_id: indicator, value: value, result_date: Time.now)
      end
    end
    render json: results
  end

  def update
    @test_result.update!(test_result_params)
    render json: @test_result
  end

  def destroy
    @test_result.void(params[:retired_reason])
    render json: {message: MessageService::RECORD_DELETED}
  end

  private

  def test_result_params
    params.permit(:test_id, test_indicators: %i[indicator value])
  end
end
