class Api::V1::CultureObservationsController < ApplicationController
  before_action :set_culture_observation, only: [:show, :update, :destroy]
  before_action :check_drug_param, only: [:drug_susceptibility_test_results]

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
    test_id = @culture_observation.test_id
    render json: Tests::CultureSensivityService.culture_ob_all(CultureObservation.where(test_id: test_id)), status: :created
  end

  def drug_susceptibility_test_results
    results = Tests::CultureSensivityService.drug_susceptibility_test_results(params)
    raise ActiveRecord::StatementInvalid if results.nil?
    render json: DrugSusceptibility.where(test_id: results.test_id), status: :created
  end

  def get_drug_susceptibility_test_results
    render json: Tests::CultureSensivityService.get_drug_susceptibility_test_results(params.require(:test_id))
  end

  def delete_drug_susceptibility_test_results
    Tests::CultureSensivityService.delete_drug_susceptibility_test_results(params)
    render json: {message: MessageService::RECORD_DELETED}
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
    render json: {message: MessageService::RECORD_DELETED}
  end

  private

  def check_drug_param
    unless params.has_key?('drugs') && params[:drugs].is_a?(Array)
      raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for drugs"
    end
  end
  def set_culture_observation
    @culture_observation = CultureObservation.find(params[:id])
  end
end
