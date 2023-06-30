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
        render json: { data: service.generate_report }
      end

      def infection
        from = params[:from]
        to = params[:to]
        department = params[:department]
        service = Reports::Aggregate::Infection.new
        render json: { data: service.generate_report(from:, to:, department:), summary: service.get_summary(department:) }
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
    end
  end
end
