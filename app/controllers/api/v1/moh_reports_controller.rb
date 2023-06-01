module Api
  module V1
    class MohReportsController < ApplicationController
      skip_before_action :authorize_request
      
      def report_indicators
        department = params.require(:department)
        render json:  case department.downcase 
                      when 'haematology'
                        haema_report.report_indicator
                      else
                        [] 
                      end
      end

      def haematology
        moh_haematology_report = haema_report
        moh_haematology_report.year = params.require(:year)
        moh_haematology_report.generate_report
        render json: moh_haematology_report.report
      end

      private

      def haema_report
        Reports::Moh::Haematology.new
      end
      
    end
  end
end
