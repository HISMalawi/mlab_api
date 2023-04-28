class Api::V1::SurveillancesController < ApplicationController
  before_action :set_api_v1_surveillance, only: %i[ show update destroy ]

  # GET /api/v1/surveillances
  def index
    @api_v1_surveillances = LabConfiguration::SurveillanceService.get_surveillances
    render json: @api_v1_surveillances
  end

  # GET /api/v1/surveillances/1
  def show
    @api_v1_surveillance = LabConfiguration::SurveillanceService.get_surveillances(params[:id])
    render json: @api_v1_surveillance
  end

  # POST /api/v1/surveillances
  def create
    accepted = params.require(:surveillance).permit(data: [:diseases_id, :test_types_id]).to_h
    Rails.logger.info accepted
    render json: LabConfiguration::SurveillanceService.create_surveillance(accepted[:data])
  end

  # PATCH/PUT /api/v1/surveillances/1
  def update
    if @api_v1_surveillance.update(surveillance_params)
      render json: @api_v1_surveillance
    else
      render json: @api_v1_surveillance.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/surveillances/1
  def destroy
    @api_v1_surveillance.destroy
  end

  private
    def surveillance_params 
      params.permit(:id, :test_types_id, :diseases_id)
    end

    def surveillance_create_params 
      params.permit(surveillances: [
        :diseases_id,
        :test_types_id
      ])
    end

    # Use callbacks to share common setup or constraints between actions.

    def set_api_v1_surveillance
      @api_v1_surveillance = Surveillance.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_surveillance_params
      params.fetch(:api_v1_surveillance, {})
    end
end
