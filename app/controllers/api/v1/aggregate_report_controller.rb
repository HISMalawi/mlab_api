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
        from, to, report_id = params.values_at(:from, :to, :report_id)
        to = to.present? ? to : today
        from = from.present? ? from : today
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Malaria.generate_report(from, to)
        )
        render json: data
      end

      def user_statistics
        service = Reports::Aggregate::UserStatistic.new
        from, to, user, report_type, page, limit, report_id = user_stat_params
        user = %w[0 undefined].include?(user) ? nil : user
        data = nil
        data ||= service.generate_report(from:, to:, user:, report_type:, page:, limit:) unless report_type == 'summary'
        data ||= Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          service.generate_report(from:, to:, user:, report_type:, page:, limit:)
        )
        render json: { data: }
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
        from, to, department, unit = params.values_at(:from, :to, :department, :unit)
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
        month, year, report_id = params.values_at(:month, :year, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Culture::GeneralCount.new.generate_report(month:, year:)
        )
        render json: data
      end

      def wards_based_count
        month, year, report_id = params.values_at(:month, :year, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Culture::WardsBased.new.generate_report(month:, year:)
        )
        render json: data
      end

      def organisms_based_count
        month, year, report_id = params.values_at(:month, :year, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Culture::OrganismsBased.new.generate_report(month:, year:)
        )
        render json: data
      end

      def organisms_in_wards_count
        month, year, report_id = params.values_at(:month, :year, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Culture::OrganismsInWardCount.new.generate_report(month:, year:)
        )
        render json: data
      end

      def ast
        month, year, report_id = params.values_at(:month, :year, :report_id)
        data = Reports::ReportCacheService.find(report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::Aggregate::Culture::Ast.new.generate_report(month:, year:)
        )
        render json: data
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

      def user_stat_params
        params.values_at(:from, :to, :user, :report_type, :page, :limit, :report_id)
      end
    end
  end
end
