# frozen_string_literal: true

# API V1 module for MoH Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to MoH Reports
    class MohReportsController < ApplicationController
      def report_indicators
        department = params.require(:department)
        render json: Reports::MohService.report_indicators(department)
      end

      def haematology
        year = params.require(:year)
        render json: Reports::MohService.generate_haematology_report(year)
      end
    end
  end
end
