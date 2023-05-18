module Api
  module V1
    class OrderStatusesController < ApplicationController

      def index 
        render json: OrderStatus.all
      end

      def specimen_rejected 
        render json: OrderStatusesService.update_order_status(order_params, "specimen-rejected")
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

    end
  end
end
