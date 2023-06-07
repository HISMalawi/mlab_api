# frozen_string_literal: true

# API V1 module for MoH Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to MoH Reports
    class MohReportsController < ApplicationController
      # skip_before_action :authorize_request, only: [:biochemistry]
      def report_indicators
        department = params.require(:department)
        render json: Reports::MohService.report_indicators(department)
      end

      def haematology
        year = params.require(:year)
        render json: Reports::MohService.generate_haematology_report(year)
      end

      def blood_bank
        year = params.require(:year)
        render json: Reports::MohService.generate_blood_bank_report(year)
      end

      def biochemistry
        year = params.require(:year)
        render json: Reports::MohService.generate_biochemistry_report(year)
      end
    end
  end
end
