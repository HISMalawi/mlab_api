class Api::V1::SurveillancesController < ApplicationController
  before_action :set_api_v1_surveillance, only: %i[ show update destroy ]

  # GET /api/v1/surveillances
  def index
    # @surveillances = LabConfiguration::SurveillanceService.get_surveillances(surveillance_params)
    page, page_size = pagination.values_at(:page, :page_size)
    total = Surveillance.count
    @surveillances = {page: page.to_i,
                    page_size: page_size.to_i,
                    total: total.to_i,
                    data: Surveillance.limit(page_size.to_i).offset(page.to_i - 1).order(created_date: :desc).all}  
    render json: @surveillances
  end

  # GET /api/v1/surveillances/1
  def show
    render json: @api_v1_surveillance
  end

  # POST /api/v1/surveillances
  def create
    accepted = params.require(:surveillance).permit(data: [:diseases_id, :test_types_id]).to_h 
    render json: accepted[:data].map { |sv| Surveillance.find_or_create_by!(**sv.merge({creator: User.current.id})) }
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
      params.permit(:id, :test_types_id, :diseases_id, :disease, :test_type, :surveillance, :format)
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

    #pagination 
    def pagination
      params.require([:page, :page_size])
      {page: params[:page], page_size: params[:page_size]}
    end
end
