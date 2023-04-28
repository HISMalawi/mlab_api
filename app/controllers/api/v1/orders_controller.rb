module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show, :update, :destroy]
    
      def index
        @orders = Order.all
        render json: @orders
      end
      
      def show
        encounter = Encounter.find_by(id: @order.encounter_id)
        render json: OrderService.show_order(@order, encounter)
      end

      def search_by_accession_or_tracking_number
        order = OrderService.search_by_accession_or_tracking_number(params[:accession_number])
        raise ActiveRecord::RecordNotFound if order.nil?
        encounter = Encounter.find_by(id: order.encounter_id)
        render json: OrderService.show_order(order, encounter)
      end
      
    
      def create
        ActiveRecord::Base.transaction do
          @encounter = OrderService.create_encounter(params)
          @order = OrderService.create_order(@encounter.id, params[:order])
          OrderService.create_test(@order.id, params[:tests])
        end
        render json: @order, status: :created
      end
    
      def update
        if @order.update(order_params)
          render json: @order
        else
          render json: @order.errors, status: :unprocessable_entity
        end
      end
    
      def destroy
        @order.destroy
      end
    
      private
    
      def set_order
        @order = Order.find(params[:id])
      end

    end
  end
end

