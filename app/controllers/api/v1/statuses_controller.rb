class Api::V1::StatusesController < ApplicationController
  before_action :set_status, only: [:show, :update, :destroy]

  def index
    @statuses = Status.where(retired: 0)
    render json: @statuses
  end
  
  def show
    if @status.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      render json: {error: false, message: MessageService::RECORD_RETRIEVED, status: @status}, status: :ok
    end
  end

  def create
    @status = Status.new(name: status_params[:name], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @status.save
      render json:  {error: false, message: MessageService::RECORD_CREATED, status: @status}, status: :created, location: [:api, :v1, @status]
    else
      render json: {error: true, message: @status.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @status.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @status.update(name: status_params[:name], updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_UPDATED, status: @status}, status: :ok
      else
        render json: {error: true, message: @status.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @status.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @status.update(retired: 1, retired_by: User.current.id, retired_reason: status_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
      else
        render json: {error: true, message: @status.errors}, status: :unprocessable_entity
      end
    end
  end

  private

  def set_status
    begin
      @status = Status.find(params[:id])
    rescue => e
      @status = nil
    end
  end

  def status_params
    params.require(:status).permit(:name, :retired_reason)
  end
end
