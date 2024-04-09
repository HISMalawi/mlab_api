# frozen_string_literal: true

# API V1 module for Aggregate Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to printing patient Reports
    class PrintPatientReportsController < ActionController::Base
      def index
        from, to, order_ids = params.values_at(:from, :to, :order_ids)
        order_id = JSON.parse(order_ids)[0]
        test_service = Tests::TestService.new
        @test_service = test_service.client_report(params[:client_id], from, to, order_id)
        @test_service = { data: @test_service, facility: GlobalService.current_location }
      end
    end
  end
end
