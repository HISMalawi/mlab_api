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
    end
  end
end
