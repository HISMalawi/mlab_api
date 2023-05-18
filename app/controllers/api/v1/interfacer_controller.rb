# frozen_string_literal: true

module Api
  module V1
    # Interfacer Controller
    class InterfacerController < ApplicationController
      skip_before_action :authorize_request, only: [:create]
      before_action :authenticate_driver, only: [:create]

      def fetch_results
        render json: read_service.new(accession_number: params[:accession_number]).read, status: :ok
      end

      def result_available
        result = read_service.new(accession_number: params[:accession_number]).read
        render json: { result_available: result.present? }, status: :ok
      end

      def create
        values = allowed_params.to_h
        Rails.logger.info(values)
        write_service.new(accession_number: values[:accession_number], machine_name: values[:machine_name], measure_id: values[:measure_id], result: values[:result]).write
        render json: { message: 'success' }, status: :ok
      end

      private

      def allowed_params
        params.permit(:accession_number, :machine_name, :measure_id, :result)
      end

      def write_service
        MachineService::WriteService
      end

      def read_service
        MachineService::ReadingService
      end

      def authenticate_driver
        username = params.require(:PHP_AUTH_USER)
        password = params.require(:PHP_AUTH_PW)

        user = User.find_by!(username:)

        render json: { message: 'Invalid Credentials' }, status: :unauthorized unless user.password_hash == password
      end
    end
  end
end
