class Api::V1::CultureObservationsController < ApplicationController
  before_action :set_culture_observation, only: [:show, :update, :destroy]

  def index
    @culture_observations = CultureObservation.where(test_id: params.require(:test_id))
    render json: Tests::CultureSensivityService.culture_ob_all(@culture_observations)
  end
  
  def show
    render json: Tests::CultureSensivityService.get_culture_obs(@culture_observation)
  end

  def create
    @culture_observation = CultureObservation.create!(
      test_id: params[:test_id],
      description: params[:description],
      observation_datetime: Time.now
    )
    render json: Tests::CultureSensivityService.get_culture_obs(@culture_observation), status: :created
  end

  def update
    @culture_observation.update!(
      test_id: params[:test_id],
      description: params[:description],
      observation_datetime: Time.now
    )
    render json: Tests::CultureSensivityService.get_culture_obs(@culture_observation)
  end

  def destroy
    @culture_observation.void(params.require(:reason))
    render json: MessageService::RECORD_DELETED
  end

  private

  def set_culture_observation
    @culture_observation = CultureObservation.find(params[:id])
  end
end
