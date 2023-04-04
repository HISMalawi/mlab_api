module Api
  module V1
    class DrugsController < ApplicationController
      before_action :set_drug, only: [:show, :update, :destroy]
    
      def index
        @drugs = Drug.all.page(params[:page]).per(params[:per_page])
        render json: {drugs: @drugs, meta: PaginationService.pagination_metadata(@drugs)}
      end
      
      def show
        render json: @drug
      end
    
      def create
        @drug = Drug.create!(drug_params)
        render json: @drug, status: :created
      end
    
      def update
        @drug.update!(drug_params)
        render json: @drug
      end
    
      def destroy
        @drug.void(params[:retired_reason])
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_drug
        @drug = Drug.find(params[:id])
      end
    
      def drug_params
        params.require(:drug).permit(:short_name, :name)
      end
    end
    
  end
end