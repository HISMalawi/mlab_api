class Api::V1::SpecimenController < ApplicationController
  before_action :set_speciman, only: [:show, :update, :destroy]

  def index
    @specimen = Specimen.all
    render json: @specimen
  end
  
  def show
    render json: @speciman
  end

  def create
    @speciman = Specimen.new(speciman_params)

    if @speciman.save
      render json: @speciman, status: :created, location: [:api, :v1, @speciman]
    else
      render json: @speciman.errors, status: :unprocessable_entity
    end
  end

  def update
    if @speciman.update(speciman_params)
      render json: @speciman
    else
      render json: @speciman.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @speciman.destroy
  end

  private

  def set_speciman
    @speciman = Specimen.find(params[:id])
  end

  def speciman_params
    params.require(:speciman).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
