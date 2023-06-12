# frozen_string_literal: true

# Api controller module
module Api
  # V1 API module
  module V1
    # Test Results controller module to handle saving of results
    class TestResultsController < ApplicationController
      def index
        render json: TestResult.all
      end

      def show
        render json: TestResult.find(params[:id])
      end

      def create
        permitted = test_result_params
        indicators = permitted[:test_indicators]
        unless permitted.key?(:test_id) && permitted.key?(:test_indicators)
          render json: { message: MessageService::MISSING_REQUIRED_PARAMETERS }, status: :bad_request and return
        end

        results = []
        ActiveRecord::Base.transaction do
          results = indicators.collect do |indicator_obj|
            indicator = indicator_obj[:indicator]
            value = indicator_obj[:value]
            machine_name = indicator_obj[:machine_name]
            unless TestIndicator.find_by_id(indicator).present?
              render json: { message: "Indicator with id #{indicator} not does not exists" },
                     status: :bad_request and return
            end

            test_result = TestResult.find_by(test_id: permitted[:test_id], test_indicator_id: indicator)
            test_result&.void('Edited')
            TestResult.create!(test_id: permitted[:test_id], test_indicator_id: indicator, value:,
                               result_date: Time.now, machine_name:)
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
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def test_result_params
        params.permit(:test_id, test_indicators: %i[indicator value machine_name])
      end
    end
  end
end
