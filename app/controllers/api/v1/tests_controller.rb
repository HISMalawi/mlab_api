# frozen_string_literal: true

module Api
  module V1
    # Test controller
    class TestsController < ApplicationController
      def index
        tests = test_service.find_tests
        render json: tests
      end

      def show
        render json: test_service.find(params[:id])
      end

      def create
        test = Test.create!(test_params)
        render json: test, status: :created
      end

      def report
        from, to, order_id = params.values_at(:from, :to, :order_id)
        render json: test_service.client_report(params[:client_id], from, to, order_id), status: :ok
      end

      def update
        Test.find(params[:id]).update!(test_params)
        render json: Test.find(params[:id]), status: :ok
      end

      def destroy
        @test.void(params[:retired_reason])
        render json: { message: MessageService::RECORD_DELETED }
      end

      def get_tests_summary
        from = params[:from]
        to = params[:to]
        department = params[:department]
        test_count = test_service.total_test_count(from, to, department)
        total_tests_count = test_service.test_statuses_count(from, to, department)

        render json: { tests_count: test_count, statuses_count: total_tests_count }
      end

      def oerr_find_test
        oerr_test = OerrService.oerr_find_test(params)
        data = if oerr_test
                 { message: 'Test found',
                   data: OerrService.to_oerr_dto(oerr_test) }
               else
                 { message: 'Test not found', data: {} }
               end
        render json: data, status: oerr_test ? 200 : 404
      end

      private

      def test_service
        Tests::TestService.new(params)
      end

      def test_params
        params.permit(:specimen_id, :order_id, :test_type_id)
      end
    end
  end
end
