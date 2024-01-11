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
        data = Report.where(year:, name: 'moh_haematology').first&.data
        data = Reports::MohService.generate_haematology_report(year) if data.nil?
        render json: data
      end

      def blood_bank
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_blood_bank').first&.data
        data = Reports::MohService.generate_blood_bank_report(year) if data.nil?
        render json: data
      end

      def biochemistry
        year = params.require(:year)
        # data = Report.where(year:, name: 'moh_biochemistry').first&.data
        data = Reports::MohService.generate_biochemistry_report(year) if data.nil?
        render json: data
      end

      def parasitology
        year = params.require(:year)
        data = if use_pregenerated_report('Parasitology', year)
                 File.read(Reports::Moh::ReportUtils.get_file_path('Parasitology', year))
               else
                 Reports::MohService.generate_parasitology_report(year)
               end
        render json: data
      end

      def microbiology
        year = params.require(:year)
        data = if use_pregenerated_report('Microbiology', year)
                 File.read(Reports::Moh::ReportUtils.get_file_path('Microbiology', year))
               else
                 Reports::MohService.generate_microbiology_report(year)
               end
        render json: data
      end

      def serology
        year = params.require(:year)
        data = Report.where(year:, name: 'moh_serology').first&.data
        data = Reports::MohService.generate_serology_report(year) if data.nil?
        render json: data
      end

      private

      def check_pregenerated_report_setting
        config_data = YAML.load_file("#{Rails.root}/config/application.yml")
        default = config_data['default']
        !default.nil? && default['pregenerate_report_moh_report'] ? true : false
      end

      def use_pregenerated_report(department, year)
        Reports::Moh::ReportUtils.check_if_file_exists(department, year) && check_pregenerated_report_setting
      end
    end
  end
end
