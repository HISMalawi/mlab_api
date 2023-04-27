class Api::V1::EncounterTypesController < ApplicationController
  # GET /encounter_types
  def index
    render json: paginate(EncounterType.all)
  end

  # GET /encounter_types/1
  def show
    render json: @encounter_type
  end

  # POST /encounter_types
  def create
    @encounter_type = EncounterType.new(encounter_type_params)

    if @encounter_type.save
      render json: @encounter_type, status: :created
    else
      render json: @encounter_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /encounter_types/1
  def update
    encounter_type = EncounterType.find(params[:id])
    encounter_type.update!(encounter_type_params)
    unless encounter_type.errors.blank?
      render json: encounter_type.errors, status: :unprocessable_entity
    end
    render json: encounter_type, status: :ok
  end

  # DELETE /encounter_types/1
  def destroy
    EncounterType.find(params[:id]).void(params[:retired_reason])
    render json: {message: MessageService::RECORD_DELETED}
  end

  private

  def encounter_type_params
    params.permit(:name, :description)
  end
end
