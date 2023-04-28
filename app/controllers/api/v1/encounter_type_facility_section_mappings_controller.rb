module Api
  module V1
    class EncounterTypeFacilitySectionMappingsController < ApplicationController
        # GET /encounter_type_facility_section_mappings
        def index
            render json: paginate(LabConfig::EncounterService.get_encounter_type_facility_section(params[:name]))
        end

        # GET /encounter_type_facility_section_mappings/1
        def show
            render json: @encounter_type_facility_section_mapping
        end

        # POST /encounter_type_facility_section_mappings
        def create
            encounter_type_facility_section_mapping = LabConfig::EncounterService.create_encounter_type_facility_section_mapping(
                                                                             encounter_type_facility_section_mapping_params)

            unless  encounter_type_facility_section_mapping.blank?
                render json:  encounter_type_facility_section_mapping, status: :created
            else
                render json:  encounter_type_facility_section_mapping.errors, status: :unprocessable_entity
            end
        end

        # PATCH/PUT /encounter_type_facility_section_mappings/1
        def update
            encounter_type_facility_section_mapping = LabConfig::EncounterService.edit_encounter_type_facility_section_mapping(params[:id], 
                                                                                encounter_type_facility_section_mapping_params)

            unless encounter_type_facility_section_mapping.blank?
                render json: encounter_type_facility_section_mapping, status: :ok
            else
                render json:  encounter_type_facility_section_mapping.errors, status: :unprocessable_entity
            end
          
        end

        # DELETE /encounter_type_facility_section_mappings/1
        def destroy
            EncounterTypeFacilitySectionMapping.find(params[:id]).void(params[:retired_reason])
            render json: { message: MessageService::RECORD_DELETED}
        end

        def encounter_type_facility_sections
            render json: LabConfig::EncounterService.get_encounter_type_facility_section(params[:encounter_type_id])
        end

        private

        def encounter_type_facility_section_mapping_params
            params.permit(:encounter_type_id, facility_section_ids: [] )
        end
    end
  end
end