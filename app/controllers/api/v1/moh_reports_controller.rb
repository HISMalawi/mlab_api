module Api
  module V1
    class MohReportsController < ApplicationController
      skip_before_action :authorize_request
      
      def haematology
        moh_haematology_report = haema_report
        moh_haematology_report.generate_report
        render json: moh_haematology_report.report
      end

      private

      def haema_report
        Reports::Moh::Haematology.new(params.require(:year))
      end
      
    end
  end
end
