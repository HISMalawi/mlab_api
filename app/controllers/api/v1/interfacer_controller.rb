# frozen_string_literal: true

module Api
  module V1
    # Interfacer Controller
    class InterfacerController < ApplicationController
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      skip_before_action :authorize_request, only: %i[index process_external_machine_results]
      before_action :authenticate_driver, only: %i[index process_external_machine_results]

      def fetch_results
        render json: read_service.new(accession_number: params[:accession_number]).read, status: :ok
      end

      def result_available
        result = read_service.new(accession_number: params[:accession_number]).read
        render json: { result_available: result.present? }, status: :ok
      end

      def index
        values = allowed_params.to_h
        Rails.logger.info(values)
        write_service.new(accession_number: values[:specimen_id], machine_name: values[:machine_name],
                          measure_id: values[:measure_id], result: values[:result]).write
        render json: { message: 'success' }, status: :ok
      end

      def process_external_machine_results
        values = allowed_params.to_h
        MachineService::ProcessGexResultsService.process(
          accession_number: values[:specimen_id],
          machine_name: values[:machine_name],
          measure_name: values[:test_type],
          result: values[:result]
        )
      end

      private

      def allowed_params
        params.permit(:specimen_id, :machine_name, :measure_id, :result, :test_type)
      end

      def write_service
        MachineService::WriteService
      end

      def read_service
        MachineService::ReadingService
      end

      def authenticate_driver
        authenticate_or_request_with_http_basic do |username, password|
          user = User.find_by!(username:)
          if user.password_hash == password
            true
          else
            render json: { message: 'Invalid Credentials' }, status: :unauthorized
          end
        end
      end
    end
  end
end
