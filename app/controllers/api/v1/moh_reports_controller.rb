module Api
  module V1
    class MohReportsController < ApplicationController
      skip_before_action :authorize_request
      
      def haematology
        year = params[:year]
        report = Reports::Moh::Haematology.generate_report(year)
        render json: report
      end
      
    end
  end
end
