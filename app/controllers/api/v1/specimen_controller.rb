class Api::V1::SpecimenController < ApplicationController
  before_action :set_specimen, only: [:show, :update, :destroy]

  def index
    @specimen = Specimen.where(retired: 0)
    render json: @specimen, status: :ok
  end
  
  def show
    if @specimen.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
     else
      render json: {error: false, message: MessageService::RECORD_RETRIEVED, specimen: @specimen}, status: :ok
     end
  end

  def create
    @specimen = Specimen.new(name: specimen_params[:name], description: specimen_params[:description], creator: User.current.id, retired: 0, created_date: Time.now, updated_date: Time.now)
    if @specimen.save
      render json:  {error: false, message: MessageService::RECORD_CREATED, specimen: @specimen}, status: :created, location: [:api, :v1, @specimen]
    else
      render json: {error: true, message: @specimen.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @specimen.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @specimen.update(name: specimen_params[:name], description: specimen_params[:description], creator: User.current.id, retired: 0, updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_UPDATED, specimen: @specimen}, status: :ok
      else
        render json: {error: true, message: @specimen.errors}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @specimen.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @specimen.update(retired: 1, retired_by: User.current.id, retired_reason: specimen_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
      else
        render json: {error: true, message: @specimen.errors}, status: :unprocessable_entity
      end
    end
  end

  private

  def set_specimen
    begin
      @specimen = Specimen.find(params[:id])
    rescue => e
      @specimen = nil
    end
  end

  def specimen_params
    params
  end
end
