# frozen_string_literal: true

# API V1 module for Aggregate Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to Aggregate Reports
    class AggregateReportController < ApplicationController
      def lab_statistics
        from, to, department, report_id = params.values_at(:from, :to, :department, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::LabStatistic.generate_report(from:, to:, department:)
        )
        render json: data
      end

      def drilldown
        associated_ids = params[:associated_ids]
        drilldown_service = Reports::DrilldownService.new(page: params[:page], limit: params[:per_page])
        render json: drilldown_service.drilldown(associated_ids)
      end

      def malaria_report
        today = Date.today.strftime('%Y-%m-%d')
        to = params[:to].present? ? params[:to] : today
        from = params[:from].present? ? params[:from] : today
        render json: Reports::Aggregate::Malaria.generate_report(from, to)
      end

      def user_statistics
        service = Reports::Aggregate::UserStatistic.new
        from = params[:from]
        to = params[:to]
        user = params[:user] == '0' ? nil : params[:user]
        report_type = params[:report_type]
        limit = params[:limit]
        page = params[:page]
        render json: { data: service.generate_report(from:, to:, user:, report_type:, page:, limit:) }
      end

      def infection
        from, to, department, report_id = params.values_at(:from, :to, :department, :report_id)
        service = Reports::Aggregate::Infection.new
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          service.generate_report(from:, to:, department:)
        )
        render json: data
      end

      def turn_around_time
        from = params[:from]
        to = params[:to]
        department = params[:department]
        unit = params[:unit]
        service = Reports::Aggregate::TurnAroundTime.new
        render json: { data: service.generate_report(from:, to:, unit:, department:) }
      end

      def rejected
        from, to, department, report_id = params.values_at(:from, :to, :department, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Rejected.generate_report(from:, to:, department:)
        )
        render json: data
      end

      def general_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::GeneralCount.new
        render json: { data: service.generate_report(month:, year:) }
      end

      def wards_based_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::WardsBased.new
        render json: { data: service.generate_report(month:, year:) }
      end

      def organisms_based_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::OrganismsBased.new
        render json: { data: service.generate_report(month:, year:) }
      end

      def organisms_in_wards_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::OrganismsInWardCount.new
        render json: { data: service.generate_report(month:, year:) }
      end

      def ast
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::Ast.new
        render json: { data: service.generate_report(month:, year:) }
      end

      def department_report
        data = Reports::ReportCacheService.find(params[:report_id])
        data ||= Reports::ReportCacheService.create(
          department_report_service.generalize_depart_report
        )
        render json: data
      end

      def tb_tests
        service = Reports::Aggregate::TbTests.new
        data = Reports::ReportCacheService.find(params[:report_id])
        data ||= Reports::ReportCacheService.create(
          service.generate_report(from: params[:from], to: params[:to])
        )
        render json: data
      end

      private

      def department_report_service
        Reports::Aggregate::DepartmentReport.new(
          params.require(:from),
          params.require(:to),
          params.require(:department)
        )
      end
    end
  end
end
