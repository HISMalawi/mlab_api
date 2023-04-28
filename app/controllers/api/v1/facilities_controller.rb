class Api::V1::FacilitiesController < ApplicationController
  def index
    render json: paginate(Facility.all)
  end
  
  def show
    render json: Facility.find(params[:id])
  end

  def create
    facility = Facility.create!(facility_params)
    render json: facility, status: :created
  end

  def update
    facility = Facility.find(params[:id]).update!(facility_params)
    render json: facility, status: :ok
  end

  def destroy
    Facility.find(params[:id]).void(params[:retired_reason])
    render json: {message: MessageService::RECORD_DELETED}
  end

  private

  def facility_params
    params.permit(:name)
  end
end
