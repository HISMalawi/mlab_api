class Api::V1::DiseasesController < ApplicationController
  before_action :set_disease, only: %i[ show update destroy ]

  # GET /api/v1/diseases
  def index
    page, page_size = pagination.values_at(:page, :page_size)
    total = Disease.count
    @diseases = {page: page.to_i,
                    page_size: page_size.to_i,
                    total: total.to_i,
                    data: Disease.limit(page_size.to_i).offset(page.to_i - 1).all}    
    render json: @diseases
  end

  # GET /api/v1/diseases/1
  def show
    render json: @disease
  end

  # POST /api/v1/diseases
  def create
    @disease = Disease.new(disease_params)
    if @disease.save
      render json: @disease, status: :created, location: [:api, :v1, @disease]
    else
      render json: @disease.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/diseases/1
  def update
    if @disease.update(disease_params)
      render json: @disease
    else
      render json: @disease.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/diseases/1
  def destroy
    @disease.destroy
  end

  private
    #disease_params 
    def disease_params 
      params.permit(:name)
    end

    #pagination 
    def pagination
      params.require([:page, :page_size])
      {page: params[:page], page_size: params[:page_size]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_disease
      @disease = Disease.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def disease_params
      params.fetch(:disease, {})
    end
end
