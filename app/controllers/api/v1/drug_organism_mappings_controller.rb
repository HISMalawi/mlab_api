class Api::V1::DrugOrganismMappingsController < ApplicationController
  before_action :set_drug_organism_mapping, only: [:show, :update, :destroy]

  def index
    @drug_organism_mappings = DrugOrganismMapping.all
    render json: @drug_organism_mappings
  end
  
  def show
    render json: @drug_organism_mapping
  end

  def create
    @drug_organism_mapping = DrugOrganismMapping.new(drug_organism_mapping_params)

    if @drug_organism_mapping.save
      render json: @drug_organism_mapping, status: :created, location: [:api, :v1, @drug_organism_mapping]
    else
      render json: @drug_organism_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @drug_organism_mapping.update(drug_organism_mapping_params)
      render json: @drug_organism_mapping
    else
      render json: @drug_organism_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @drug_organism_mapping.destroy
  end

  private

  def set_drug_organism_mapping
    @drug_organism_mapping = DrugOrganismMapping.find(params[:id])
  end

  def drug_organism_mapping_params
    params.require(:drug_organism_mapping).permit(:drug_id, :organism_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
