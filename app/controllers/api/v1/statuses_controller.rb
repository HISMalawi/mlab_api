class Api::V1::StatusesController < ApplicationController
  before_action :set_status, only: [:show, :update, :destroy]

  def index
    @statuses = Status.all
    render json: @statuses
  end
  
  def show
    render json: @status
  end

  def create
    @status = Status.new(status_params)

    if @status.save
      render json: @status, status: :created, location: [:api, :v1, @status]
    else
      render json: @status.errors, status: :unprocessable_entity
    end
  end

  def update
    if @status.update(status_params)
      render json: @status
    else
      render json: @status.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @status.destroy
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :updated_date_copy1)
  end
end
