# frozen_string_literal: true

# Module API
module Api
  # Module V1
  module V1
    # Home Dashboard Analytics Controller
    class AnalyticsController < ApplicationController
      def home_dashboard
        home_params
        HomeDashboardService.test_catalog unless home_dashboard_report?('test_catalog', @department)
        HomeDashboardService.lab_configuration unless home_dashboard_report?('lab_config', @department)
        HomeDashboardService.clients unless home_dashboard_report?('clients', @department)
        HomeDashboardService.tests(@from, @to, @department) unless home_dashboard_report?('tests', @department)
        data = HomeDashboard.all.map { |dashboard| dashboard[:data] }.reduce({}, :merge)
        render json: { data:, from: @from, to: @to }
      end

      private

      def home_dashboard_report?(report_type, department)
        department = 'All' if department.nil? || department == 'Lab Reception'
        !HomeDashboard.where(report_type:, department:).first.nil?
      end

      def home_params
        @to = params[:to].present? ? Date.parse(params[:to]) : Date.today
        @from = params[:from].present? ? Date.parse(params[:from]) : @to - 30
        @department = params[:department]
      end
    end
  end
end
