module Api
  module V1
    class OrderStatusesController < ApplicationController

      def index 
        render json: OrderStatus.all
      end

      def specimen_rejected
        render json: OrderStatusesService.reject_order(reject_params)
      end

      def specimen_accepted
        render json: OrderStatusesService.update_order_status(order_params, "specimen-accepted")
      end

      def specimen_not_collected
        render json: OrderStatusesService.update_order_status(order_params, "specimen-not-collected")
      end

      private
      def order_params
        params.require(:order_status).permit(:order_id, :status_id, :status_reason_id, :person_talked_to)
      end

      # Rejection can target the whole order (specimen rejected -> every test
      # rejected too) or only specific tests (specimen still usable for the
      # rest -> order status untouched). `test_ids`, `reject_all` and
      # `other_reason` are not order_status attributes, so they are not wrapped
      # and are read from the top level.
      def reject_params
        order_params.to_h.symbolize_keys.merge(
          test_ids: Array(params[:test_ids]).map(&:to_i),
          reject_all: ActiveModel::Type::Boolean.new.cast(params[:reject_all]),
          other_reason: params[:other_reason]
        )
      end

    end
  end
end
