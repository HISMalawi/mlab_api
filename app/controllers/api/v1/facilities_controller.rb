class Api::V1::FacilitiesController < ApplicationController
  before_action :set_facility, only: [:show, :update, :destroy]

  def index
    @facilities = Facility.all
    render json: @facilities
  end
  
  def show
    render json: @facility
  end

  def create
    @facility = Facility.new(facility_params)

    if @facility.save
      render json: @facility, status: :created, location: [:api, :v1, @facility]
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  def update
    if @facility.update(facility_params)
      render json: @facility
    else
      render json: @facility.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @facility.destroy
  end

  private

  def set_facility
    @facility = Facility.find(params[:id])
  end

  def facility_params
    params.require(:facility).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
