module Api
  module V1
    class AnalyticsController < ApplicationController
      def home_dashboard
        # debugger
        to = params[:to].present? ? Date.parse(params[:to]) : Date.today
        from = params[:from].present? ? Date.parse(params[:from]) : to - 30
        department = params[:department]
        HomeDashboardAnalytics.test_catalog unless home_dashboard_report?('test_catalog', department)
        HomeDashboardAnalytics.lab_configuration unless home_dashboard_report?('lab_config', department)
        HomeDashboardAnalytics.clients unless home_dashboard_report?('clients', department)
        HomeDashboardAnalytics.tests(from, to, department) unless home_dashboard_report?('tests', department)
        data = HomeDashboard.all.map { |dashboard| dashboard[:data] }.reduce({}, :merge)
        render json: data
      end

      private

      def home_dashboard_report?(report_type, department)
        department = 'All' if department.nil? || department == 'Lab Reception'
        !HomeDashboard.where(report_type:, department:).first.nil?
      end
    end
  end
end
