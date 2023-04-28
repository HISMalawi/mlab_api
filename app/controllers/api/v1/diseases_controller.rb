class Api::V1::DiseasesController < ApplicationController
  before_action :set_api_v1_disease, only: %i[ show update destroy ]

  # GET /api/v1/diseases
  def index
    @api_v1_diseases = Disease.all
    render json: @api_v1_diseases
  end

  # GET /api/v1/diseases/1
  def show
    render json: @api_v1_disease
  end

  # POST /api/v1/diseases
  def create
    @api_v1_disease = Disease.new(disease_params)
    if @api_v1_disease.save
      render json: @api_v1_disease, status: :created, location: [:api, :v1, @api_v1_disease]
    else
      render json: @api_v1_disease.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/diseases/1
  def update
    if @api_v1_disease.update(disease_params)
      render json: @api_v1_disease
    else
      render json: @api_v1_disease.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/diseases/1
  def destroy
    @api_v1_disease.destroy
  end

  private
    #disease_params 
    def disease_params 
      params.permit(:name)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_api_v1_disease
      @api_v1_disease = Disease.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def api_v1_disease_params
      params.fetch(:api_v1_disease, {})
    end
end
