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

      def specimen_test_type
        specimen = Specimen.find(params[:specimen_id])
        test_types = SpecimenTestTypeMapping.joins(:test_type).where(specimen_id: specimen.id)
        test_types = test_types.where("test_types.department_id = #{params[:department_id]}") if !params[:department_id].blank?
        test_panel = TestTypePanelMapping.joins(:test_panel).joins(:test_type).where(test_type_id: test_types).pluck('test_panels.name')
        test_types = test_types.pluck('name') + (test_panel)
        render json: test_types.uniq
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
        render json: {message: MessageService::RECORD_DELETED}
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
