module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show, :update, :destroy]
      before_action :nlims, only: [:search_order_from_nlims_by_tracking_number, :merge_order_from_nlims]
    
      def index
        @orders = Order.all
        render json: @orders
      end
      
      def show
        encounter = Encounter.find_by(id: @order.encounter_id)
        render json: OrderService.show_order(@order, encounter)
      end

      def search_order_from_nlims_by_tracking_number
        response = @nlims_service.query_order_by_tracking_number(params.require(:tracking_number))
        raise NlimsNotFoundError, 'Order not available in NLIMS' if response.nil?
        render json: response
      end

      def search_by_accession_or_tracking_number
        order = OrderService.search_by_accession_or_tracking_number(params[:accession_number])
        raise ActiveRecord::RecordNotFound if order.nil?
        encounter = Encounter.find_by(id: order.encounter_id)
        render json: OrderService.show_order(order, encounter)
      end

      def merge_order_from_nlims
        order = @nlims_service.merge_or_create_order(params)
        render json: order, status: :created
      end
      
      def add_test_to_order
        order = OrderService.add_test_to_order(params[:order_id], params[:tests])
        render json: order, status: :created
      end

      def search_by_requesting_clinician
        render json: Order.requesting_clinician(params[:name])
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

      def nlims
        config_data = YAML.load_file("#{Rails.root}/config/application.yml")
        nlims_config = config_data["nlims_service"] 
        raise NlimsError, "nlims_service configuration not found" if nlims_config.nil?
        @nlims_service = Nlims::RemoteService.new(
          base_url: "#{nlims_config['base_url']}:#{nlims_config['port']}",
          token: '',
          username: nlims_config['username'],
          password: nlims_config['password']
        )
        if @nlims_service.ping_nlims
          auth = @nlims_service.authenticate
          raise NlimsError, "Unable to authenticate to nlims service" if !auth
        else
          raise Errno::ECONNREFUSED, "Nlims service is not available"
        end
      end
    
      def set_order
        @order = Order.find(params[:id])
      end

    end
  end
end

