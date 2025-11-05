module Api
  module V1
    class DiseasesController < ApplicationController
      before_action :set_disease, only: %i[show update destroy]

      # GET /api/v1/diseases
      def index
        render json: Disease.all
      end

      # GET /api/v1/diseases/1
      def show
        render json: @disease
      end

      # POST /api/v1/diseases
      def create
        diseases = params.require(:disease).permit(data: [:name]).to_h
        diseases = diseases[:data].map do |ds|
          name = ds[:name].to_s.strip
          disease = Disease.unscoped.find_by(name:)
          if disease
            disease.update!(voided: 0, voided_reason: nil, name:)
          else
            Disease.create!(name:)
          end
        end
        render json: diseases
      end

      # PATCH/PUT /api/v1/diseases/1
      def update
        @disease.update!(disease_params)
        render json: @disease, status: :ok
      end

      # DELETE /api/v1/diseases/1
      def destroy
        render json: @disease.void(disease_params[:voided_reason])
      end

      private

      # Only allow a list of trusted parameters through.
      def disease_params
        params.require(:disease).permit(:name, :id, :voided_reason)
      end

      # pagination
      def pagination
        params.require(%i[page page_size])
        { page: params[:page], page_size: params[:page_size] }
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_disease
        @disease = Disease.find(params[:id])
      end
    end
  end
end
