# frozen_string_literal: true

# Module API
module Api
  # Module V1
  module V1
    # Home Dashboard Analytics Controller
    class AnalyticsController < ApplicationController
      def home_dashboard
        home_params
        if home_dashboard_report?('tests', @department, @lab_location)
          HomeDashboardService.test_catalog
          HomeDashboardService.lab_configuration
          HomeDashboardService.tests(@from, @to, @department, @lab_location)
        end
        HomeDashboardService.clients(@lab_location) if home_dashboard_report?('clients', @department, @lab_location)
        other_report_types = %w[lab_config test_catalog]
        other_data = HomeDashboard.where(department: 'All', report_type: other_report_types, lab_location_id: 1)
        clients_data = HomeDashboard.where(department: 'All', report_type: 'clients', lab_location_id: @lab_location)
        tests_data = HomeDashboard.where(department: @department, report_type: 'tests', lab_location_id: @lab_location)
        combine_data = tests_data + other_data + clients_data
        data = combine_data.map { |dashboard| dashboard[:data] }.reduce({}, :merge)
        nlims = Nlims::Sync.nlims_token
        data[:nlims_status] = nlims[:token].present? && nlims[:base_url].present? ? 'Active' : 'Inactive'
        render json: { data:, from: @from, to: @to }
      end

      private

      def home_dashboard_report?(report_type, department, lab_location_id)
        department = 'All' if department.nil? || department == 'Lab Reception'
        department = 'All' if report_type != 'tests'
        HomeDashboard.where(report_type:, department:, lab_location_id:).first.nil?
      end

      def home_params
        @to = params[:to].present? ? Date.parse(params[:to]) : Date.today
        @from = params[:from].present? ? Date.parse(params[:from]) : @to - 30
        @department = if params[:department].nil? || params[:department] == 'Lab Reception'
                        'All'
                      else
                        params[:department]
                      end
        @lab_location = params[:lab_location].present? ? params[:lab_location] : 1
      end
    end
  end
end
