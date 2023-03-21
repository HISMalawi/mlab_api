class Api::V1::StatusReasonsController < ApplicationController
  before_action :set_status_reason, only: [:show, :update, :destroy]

  def index
    @status_reasons = StatusReason.where(retired: 0)
    render json: @status_reasons
  end
  
  def show
    if @status_reason.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      render json: {error: false, message: MessageService::RECORD_RETRIEVED, status_reason: @status_reason}, status: :ok
    end
  end

  def create
    @status_reason = StatusReason.new(description: status_reason_params[:description], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @status_reason.save
      render json:  {error: false, message: MessageService::RECORD_CREATED, status_reason: @status_reason}, status: :created, location: [:api, :v1, @status_reason]
    else
      render json: {error: true, message: @status_reason.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @status_reason.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @status_reason.update(description: status_reason_params[:description], updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_UPDATED, status_reason: @status_reason}, status: :ok
      else
        render json: {error: true, message: @status_reason.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @status_reason.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @status_reason.update(retired: 1, retired_by: User.current.id, retired_reason: status_reason_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
      else
        render json: {error: true, message: @status_reason.errors}, status: :unprocessable_entity
      end
    end
  end

  private

  def set_status_reason
    begin
      @status_reason = StatusReason.find(params[:id])
    rescue => e
      @status_reason = nil
    end
  end

  def status_reason_params
    params.require(:status_reason).permit(:description, :retired_reason)
  end
end
