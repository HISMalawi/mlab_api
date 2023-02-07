class Api::V1::StatusReasonsController < ApplicationController
  before_action :set_status_reason, only: [:show, :update, :destroy]

  def index
    @status_reasons = StatusReason.all
    render json: @status_reasons
  end
  
  def show
    render json: @status_reason
  end

  def create
    @status_reason = StatusReason.new(status_reason_params)

    if @status_reason.save
      render json: @status_reason, status: :created, location: [:api, :v1, @status_reason]
    else
      render json: @status_reason.errors, status: :unprocessable_entity
    end
  end

  def update
    if @status_reason.update(status_reason_params)
      render json: @status_reason
    else
      render json: @status_reason.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @status_reason.destroy
  end

  private

  def set_status_reason
    @status_reason = StatusReason.find(params[:id])
  end

  def status_reason_params
    params.require(:status_reason).permit(:description, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
