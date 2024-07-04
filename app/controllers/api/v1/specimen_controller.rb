# frozen_string_literal: true

module Api
  module V1
    # Specimen controller
    class SpecimenController < ApplicationController
      before_action :set_specimen, only: %i[show update destroy]

      def index
        @specimens = service.specimen(department_id: params[:department_id])
        render json: @specimens
      end

      def show
        render json: @specimen
      end

      def specimen_test_type
        test_types = service.specimen_test_type(params[:specimen_id], params[:department_id], params[:sex])
        render json: test_types
      end

      def create
        @specimen = Specimen.create!(specimen_params)
        render json: @specimen, status: :created
      end

      def update
        @specimen.update!(specimen_params)
        render json: @specimen
      end

      def destroy
        @specimen.void(params[:retired_reason])
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def set_specimen
        @specimen = Specimen.find(params[:id])
      end

      def service
        TestCatalog::SpecimenService
      end

      def specimen_params
        params.require(:speciman).permit(:name, :description)
      end
    end
  end
end
