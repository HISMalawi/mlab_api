class Api::V1::FacilitySectionsController < ApplicationController
  before_action :set_facility_section, only: [:show, :update, :destroy]

  def index
    @facility_sections = FacilitySection.all
    render json: @facility_sections
  end
  
  def show
    render json: @facility_section
  end

  def create
    @facility_section = FacilitySection.new(facility_section_params)

    if @facility_section.save
      render json: @facility_section, status: :created, location: [:api, :v1, @facility_section]
    else
      render json: @facility_section.errors, status: :unprocessable_entity
    end
  end

  def update
    if @facility_section.update(facility_section_params)
      render json: @facility_section
    else
      render json: @facility_section.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @facility_section.destroy
  end

  private

  def set_facility_section
    @facility_section = FacilitySection.find(params[:id])
  end

  def facility_section_params
    params.require(:facility_section).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
