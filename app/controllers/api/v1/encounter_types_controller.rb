module Api
  module V1
    class EncounterTypesController < ApplicationController
      def index
        render json: paginate(EncounterType.all)
      end

      def show
        render json: EncounterType.find(params[:id])
      end

      def create
        render json: encounter_type_service.create_encounter_type(encounter_type_params), status: :created
      end
      
      def update
        render json: encounter_type_service.update_encounter_type(EncounterType.find(params[:id]), encounter_type_params), status: :ok
      end

      def destroy
        EncounterType.find(params[:id]).void(params[:retired_reason])
        EncounterTypeFacilitySectionMapping.where(encounter_type_id: params[:id]).each do |mapping|
          mapping.void(params[:retired_reason])
        end
        render json: { message: "Visit type successfully deleted" }, status: :ok
      end

      private

      def encounter_type_service
        EncounterTypeService
      end

      def encounter_type_params
        params.permit(:name, :description, facility_sections: [])
      end
    end
  end
end