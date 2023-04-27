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
    if @encounter_type.update(encounter_type_params)
      render json: @encounter_type
    else
      render json: @encounter_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /encounter_types/1
  def destroy
    @encounter_type.destroy
  end

  private

  def encounter_type_params
    params.permit(:name, :description)
  end
end
