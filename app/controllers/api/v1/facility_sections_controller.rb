class Api::V1::FacilitySectionsController < ApplicationController
  def index
    if params[:search].present?
      facility_sections = FacilitySection.where(
        "name LIKE '%#{params[:search]}%'"
      )
    else
      facility_sections = FacilitySection.all
    end
    return render json: { data: facility_sections } unless params[:page].present?

    render json: paginate(facility_sections)
  end

  def show
    render json: FacilitySection.find(params[:id])
  end

  def create
    section = FacilitySection.create(facility_section_params)
    render json: section, status: :created
  end

  def update
    section = FacilitySection.find(params[:id]).update(facility_section_params)
    render json: section, status: :ok
  end

  def destroy
    FacilitySection.find(params[:id]).void(params[:retired_reason])
    render json: MessageService::RECORD_DELETED, status: :ok
  end

  private

  def facility_section_params
    params.permit(:name)
  end
end
