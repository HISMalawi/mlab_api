module Api
  module V1
    class AnalyticsController < ApplicationController
      def lab_config_summary
        service = LabConfig::AnalyticsService.new
        analytics = service.test_catalog_summary
        render json: { data: analytics }
      end

      def clients_summary
        service = ClientManagement::AnalyticsService.new
        analytics = service.get_clients_summary
        render json: { data: analytics }
      end
    end
  end
end
