module Api
  module V1
    class SpecimenController < ApplicationController
      before_action :set_specimen, only: [:show, :update, :destroy]
    
      def index
        @specimen = Specimen.all
        render json: @specimen
      end
      
      def show
        render json: @specimen
      end
    
      def create
        @specimen = Specimen.create!(specimen_params)
        render json: @specimen, status: :created
      end
    
      def update
        @specimen.update!(specimen_params)
        render json: @specimen
      end
    
      def destroy
        @specimen.void(params[:retired_reason])
        render json: @specimen
      end
    
      private
    
      def set_specimen
        @specimen = Specimen.find(params[:id])
      end
    
      def specimen_params
        params.require(:speciman).permit(:name, :description)
      end
    end
  end
end
