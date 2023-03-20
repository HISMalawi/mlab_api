class Api::V1::DrugsController < ApplicationController
  before_action :set_drug, only: [:show, :update, :destroy]

  def index
    @drugs = Drug.where(retired: 0)
    render json: @drugs
  end
  
  def show
    if @drug.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else 
      render json: {error: false, message: MessageService::RECORD_RETRIEVED, drug: @drug}, status: :ok
    end
  end

  def create
    @drug = Drug.new(short_name: drug_params[:short_name], name: drug_params[:name], creator: User.current.id, retired: 0, created_date: Time.now, updated_date: Time.now)

    if @drug.save
      render json: {error: false, message: MessageService::RECORD_CREATED, drug: @drug}, status: :created, location: [:api, :v1, @drug]
    else
      render json: {error: true, message: @drug.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @drug.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else 
      if @drug.update(name: drug_params[:name], short_name: drug_params[:short_name],  updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_UPDATED, drug: @drug}, status: :ok
      else
        render json: {error: true, message: @drug.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @drug.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else 
      if @drug.update(retired: 1, retired_by: User.current.id, retired_reason: drug_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
      else
        render json: {error: true, message: @drug.errors}, status: :unprocessable_entity
      end
    end
  end

  private

  def set_drug
    begin
      @drug = Drug.find(params[:id])
    rescue => e
      @drug = nil
    end
  end

  def drug_params
    params.require(:drug).permit(:short_name, :name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
