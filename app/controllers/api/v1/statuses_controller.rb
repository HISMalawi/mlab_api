class Api::V1::StatusesController < ApplicationController
  before_action :set_status, only: [:show, :update, :destroy]

  def index
    @statuses = Status.where(retired: 0)
    render json: @statuses
  end
  
  def show
    render json: @status
  end

  def create
    @status = Status.new(name: status_params[:name], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @status.save
      render json: @status, status: :created, location: [:api, :v1, @status]
    else
      render json: @status.errors, status: :unprocessable_entity
    end
  end

  def update
    if @status.update(name: status_params[:name], updated_date: Time.now)
      render json: @status
    else
      render json: @status.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @status.update(retired: 1, retired_by: User.current.id, retired_reason: status_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
      render json: @status
    else
      render json: @status.errors, status: :unprocessable_entity
    end
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:name, :retired_reason)
  end
end
