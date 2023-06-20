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
        data_by_ward = Reports::Aggregate::Malaria.query_data_by_ward(from:, to:)
        data_by_gender = Reports::Aggregate::Malaria.query_data_by_gender(from:, to:)
        summary_by_ward = Reports::Aggregate::Malaria.process_data_by_ward(data_by_ward)
        render json: {
          from:,
          to:,
          data_by_ward:,
          data_by_gender:,
          summary_by_ward:
        }
      end
    end
  end
end
