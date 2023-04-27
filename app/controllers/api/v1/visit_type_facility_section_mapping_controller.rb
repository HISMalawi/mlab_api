class Api::V1::VisitTypeFacilitySectionMappingController < ApplicationController
  before_action :set_visit_type_facility_section_mappings, only: [:show, :update, :destroy]
 
  def index
    @visit_type_facility_section_mappings = VisitTypeFacilitySectionMapping.all
    render json: @visit_type_facility_section_mappings
  end
  
  def show
    render json: @visit_type_facility_section_mappings
  end

  def create
    @visit_type_facility_section_mappings = VisitTypeFacilitySectionMapping.new(visit_type_facility_section_mappings_params)

    if @visit_type_facility_section_mappings.save
      render json: @visit_type_facility_section_mappings, status: :created, location: [:api, :v1, @visit_type_facility_section_mappings]
    else
      render json: @visit_type_facility_section_mappings.errors, status: :unprocessable_entity
    end
  end

  def update
    if @visit_type_facility_section_mappings.update(visit_type_facility_section_mappings_params)
      render json: @visit_type_facility_section_mappings
    else
      render json: @visit_type_facility_section_mappings.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @visit_type_facility_section_mappings.destroy
  end

  private

  def set_visit_type_facility_section_mappings
    @visit_type_facility_section_mappings = UserRoleMapping.find(params[:id])
  end

  def visit_type_facility_section_mappings_params
    params.require(:visit_type_facility_section_mapping).permit(:user_id, :role_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end

end
