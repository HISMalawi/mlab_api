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
        test_id = permitted[:test_id]
        indicators = permitted[:test_indicators]
        remarks = permitted[:remarks]
        unless permitted.key?(:test_id) && permitted.key?(:test_indicators)
          render json: { message: MessageService::MISSING_REQUIRED_PARAMETERS }, status: :bad_request and return
        end

        results = []
        ActiveRecord::Base.transaction do
          Remark.find_or_create_by(tests_id: test_id).update(value: remarks)
          results = indicators.collect do |indicator_obj|
            test_indicator_id = indicator_obj[:indicator]
            value = indicator_obj[:value]
            machine_name = indicator_obj[:machine_name]
            unless TestIndicator.find_by_id(test_indicator_id).present?
              render json: { message: "Indicator with id #{test_indicator_id} not does not exists" },
                     status: :bad_request and return
            end

            # Handle cross match results with same pack number
            void_previous_x_matches(test_indicator_id, value) if Test.find(test_id).test_type_id == 30
            test_result = TestResult.find_by(test_id:, test_indicator_id:)
            test_result&.void('Edited')
            TestResult.create!(test_id:, test_indicator_id:, value:,
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
        params.permit(:test_id, :remarks, test_indicators: %i[indicator value machine_name])
      end

      def void_previous_x_matches(test_indicator_id, value)
        return if value.blank? || test_indicator_id != 126

        test_ids = TestResult.where(test_indicator_id:, value:).order(created_date: :desc).limit(100).pluck('test_id')
        test_results = TestResult.where(test_id: test_ids)
        test_results.each do |result|
          result.void("Voided due to having same pack number result as #{test_ids}")
        end
      end
    end
  end
end
