class Api::V1::SpecimenController < ApplicationController
  before_action :set_specimen, only: [:show, :update, :destroy]

  def index
    @specimen = Specimen.where(retired: 0)
    render json: @specimen, status: :ok
  end
  
  def show
    render json: @specimen
  end

  def create
    @specimen = Specimen.new(name: specimen_params[:name], creator: User.current.id, retired: 0, created_date: Time.now, updated_date: Time.now)

    if @specimen.save
      render json: @specimen, status: :created, location: [:api, :v1, @specimen]
    else
      render json: @specimen.errors, status: :unprocessable_entity
    end
  end

  def update
    if @specimen.update(name: specimen_params[:name], creator: User.current.id, retired: 0, updated_date: Time.now)
      render json: @specimen, status: :ok
    else
      render json: @specimen.errors, status: :unprocessable_entity
    end
  end

  def destroy
   if @specimen.update(name: specimen_params[:name], retired: 1, retired_by: User.current.id, 
      retired_reason: specimen_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
      render json: @specimen, status: :ok
   else
      render json: @specimen.errors, status: :unprocessable_entity
   end
  end

  private

  def set_specimen
    @specimen = Specimen.find(params[:id])
  end

  def specimen_params
    params.require(:speciman).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
