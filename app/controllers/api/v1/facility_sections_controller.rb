class Api::V1::FacilitySectionsController < ApplicationController

  def index
    render json: paginate(FacilitySection.all)
  end
  
  def show
    render json: FacilitySection.find(params[:id])
  end

  def create
    section = FacilitySection.create(facility_section_params)
    render json: section
  end

  def update
    section = FacilitySection.find(params[:id]).update(facility_section_params)
    render json: section
  end

  def destroy
    FacilitySection.find(params[:id]).void(params[:retired_reason])
  end

  private

  def facility_section_params
    params.permit(:name)
  end
end
