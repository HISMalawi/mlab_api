# frozen_string_literal: true

# API V1 module for MoH Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to MoH Reports
    class MohReportsController < ApplicationController
      before_action :report_params
      skip_before_action :report_params, only: %i[report_indicators]

      def report_indicators
        department = params.require(:department)
        render json: Reports::MohService.report_indicators(department)
      end

      def haematology
        data = Reports::ReportCacheService.find(@report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::MohService.generate_haematology_report(@year)
        )
        render json: data
      end

      def blood_bank
        data = Reports::ReportCacheService.find(@report_id)
        data ||= Reports::ReportCacheService.create(
          Reports::MohService.generate_blood_bank_report(@year)
        )
        render json: data
      end

      def biochemistry
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_biochemistry').first&.data
        data = Reports::MohService.generate_biochemistry_report(year) if data.nil?
        render json: data
      end

      def parasitology
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_parasitology').first&.data
        data = Reports::MohService.generate_parasitology_report(year) if data.nil?
        render json: data
      end

      def microbiology
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_microbiology').first&.data
        data = Reports::MohService.generate_microbiology_report(year) if data.nil?
        render json: data
      end

      def serology
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_serology').first&.data
        data = Reports::MohService.generate_serology_report(year) if data.nil?
        render json: data
      end

      private

      def report_params
        @year = params.require(:year)
        @report_id = params[:report_id]
      end
    end
  end
end
