# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock PharmacyApproverIssuer controller
    class StockPharmacyApproverAndIssuersController < ApplicationController
      before_action :set_pharmacy_approver_issuer, only: %i[show update destroy]

      def index
        pharmacy_approver_issuers = StockPharmacyApproverAndIssuer.all
        render json: pharmacy_approver_issuers
      end

      def create
        pharmacy_approver_issuer = StockPharmacyApproverAndIssuer.create!(
          stock_pham_app_issuer_params
        )
        render json: pharmacy_approver_issuer, status: :created
      end

      def show
        render json: @pharmacy_approver_issuer
      end

      def update
        @pharmacy_approver_issuer.update!(stock_pham_app_issuer_params)
        render json: @stock_unit, status: :ok
      end

      def destroy
        @pharmacy_approver_issuer.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_pham_app_issuer_params
        params.require(:stock_pharmacy_approver_and_issuer).permit(
          :stock_order_id,
          :name,
          :designation,
          :phone_number,
          :signature,
          :record_type
        )
      end

      def set_pharmacy_approver_issuer
        @pharmacy_approver_issuer = StockPharmacyApproverAndIssuer.find(params[:id])
      end
    end
  end
end
