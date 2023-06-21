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
    end
  end
end
