class Api::V1::CultureObservationsController < ApplicationController
  before_action :set_culture_observation, only: [:show, :update, :destroy]

  def index
    @culture_observations = CultureObservation.all
    render json: @culture_observations
  end
  
  def show
    render json: @culture_observation
  end

  def create
    @culture_observation = CultureObservation.new(culture_observation_params)

    if @culture_observation.save
      render json: @culture_observation, status: :created, location: [:api, :v1, @culture_observation]
    else
      render json: @culture_observation.errors, status: :unprocessable_entity
    end
  end

  def update
    if @culture_observation.update(culture_observation_params)
      render json: @culture_observation
    else
      render json: @culture_observation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @culture_observation.destroy
  end

  private

  def set_culture_observation
    @culture_observation = CultureObservation.find(params[:id])
  end

  def culture_observation_params
    params.require(:culture_observation).permit(:test_id, :description, :observation_datetime, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end
