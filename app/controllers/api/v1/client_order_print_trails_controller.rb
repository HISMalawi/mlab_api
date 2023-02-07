class Api::V1::ClientOrderPrintTrailsController < ApplicationController
  before_action :set_client_order_print_trail, only: [:show, :update, :destroy]

  def index
    @client_order_print_trails = ClientOrderPrintTrail.all
    render json: @client_order_print_trails
  end
  
  def show
    render json: @client_order_print_trail
  end

  def create
    @client_order_print_trail = ClientOrderPrintTrail.new(client_order_print_trail_params)

    if @client_order_print_trail.save
      render json: @client_order_print_trail, status: :created, location: [:api, :v1, @client_order_print_trail]
    else
      render json: @client_order_print_trail.errors, status: :unprocessable_entity
    end
  end

  def update
    if @client_order_print_trail.update(client_order_print_trail_params)
      render json: @client_order_print_trail
    else
      render json: @client_order_print_trail.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @client_order_print_trail.destroy
  end

  private

  def set_client_order_print_trail
    @client_order_print_trail = ClientOrderPrintTrail.find(params[:id])
  end

  def client_order_print_trail_params
    params.require(:client_order_print_trail).permit(:order_id, :creator, :voided, :voided_by, :voided_reason, :voided_date)
  end
end
