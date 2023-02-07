class Api::V1::EncountersController < ApplicationController
  before_action :set_encounter, only: [:show, :update, :destroy]

  def index
    @encounters = Encounter.all
    render json: @encounters
  end
  
  def show
    render json: @encounter
  end

  def create
    @encounter = Encounter.new(encounter_params)

    if @encounter.save
      render json: @encounter, status: :created, location: [:api, :v1, @encounter]
    else
      render json: @encounter.errors, status: :unprocessable_entity
    end
  end

  def update
    if @encounter.update(encounter_params)
      render json: @encounter
    else
      render json: @encounter.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @encounter.destroy
  end

  private

  def set_encounter
    @encounter = Encounter.find(params[:id])
  end

  def encounter_params
    params.require(:encounter).permit(:client_id, :facility_id, :destination_id, :facility_section_id, :start_date, :end_date, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date, :uuid)
  end
end
