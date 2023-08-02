# frozen_string_literal: true

# API V1 module for Aggregate Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to Aggregate Reports
    class AggregateReportController < ApplicationController
      def lab_statistics
        from = params[:from]
        to = params[:to]
        department = params[:department]
        render json: Reports::Aggregate::LabStatistic.generate_report(from:, to:, department:)
      end

      def malaria_report
        today = Date.today.strftime("%Y-%m-%d")
        to = params[:to].present? ? params[:to] : today
        from = params[:from].present? ? params[:from] : today
        render json: Reports::Aggregate::Malaria.generate_report(from, to)
      end

      def user_statistics
        service = Reports::Aggregate::UserStatistic.new
        from = params[:from]
        to = params[:to]
        user = params[:user]
        report_type = params[:report_type]
        limit = params[:limit]
        page = params[:page]
        render json: { data: service.generate_report(from:, to:, user:, report_type:, page:, limit:) }
      end

      def infection
        from = params[:from]
        to = params[:to]
        department = params[:department]
        service = Reports::Aggregate::Infection.new
        render json: { data: service.generate_report(from:, to:, department:), summary: service.get_summary(department:, from:, to:) }
      end

      def turn_around_time
        from = params[:from]
        to = params[:to]
        department = params[:department]
        service = Reports::Aggregate::TurnAroundTime.new
        render json: { data: service.generate_report(from:, to:, department:)}
      end

      def rejected
        from = params[:from]
        to = params[:to]
        department = params[:department]
        service = Reports::Aggregate::Rejected.new
        render json: { data: service.generate_report(from:, to:, department:)}
      end

      def general_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::GeneralCount.new
        render json: { data: service.generate_report(month:, year:)}
      end

      def wards_based_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::WardsBased.new
        render json: { data: service.generate_report(month:, year:)}
      end

      def organisms_based_count
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::OrganismsBased.new
        render json: { data: service.generate_report(month:, year:)}
      end

      def organisms_in_wards_count
        month = params[:month]
        year = params[:year]
        department = params[:department]
        service = Reports::Aggregate::Culture::OrganismsInWardCount.new
        render json: { data: service.generate_report(month:, year:, department:)}
      end

      def ast
        month = params[:month]
        year = params[:year]
        service = Reports::Aggregate::Culture::Ast.new
        render json: { data: service.generate_report(month:, year:)}
      end

      def department_report
        render json: department_report_service.generalize_depart_report
      end

      def tb_tests
        from = params[:from]
        to = params[:to]
        service = Reports::Aggregate::TbTests.new
        render json: service.generate_report(from:, to:)
      end

      private

      def department_report_service
        Reports::Aggregate::DepartmentReport.new(params.require(:from), params.require(:to), params.require(:department))
      end
    end
  end
end
