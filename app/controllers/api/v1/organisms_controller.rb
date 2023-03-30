class Api::V1::OrganismsController < ApplicationController
  before_action :set_organism, only: [:show, :update, :destroy]

  def index
    @organisms = Organism.all
    render json: @organisms
  end
  
  def show
    drugs = DrugOrganismMapping.joins(:drug).where(organism_id: @organism.id).select('drugs.id, drugs.name, drugs.short_name')
    render json: serialize_organism_drug(@organism, drugs)
  end

  def create
    ActiveRecord::Base.transaction do
      @organism = Organism.create!(organism_params)
      if params.has_key?('drugs') && params[:drugs].is_a?(Array)
        params[:drugs].each do |drug|
          DrugOrganismMapping.create!(drug_id: drug, organism_id: @organism.id)
        end
      end
    end
    render json: @organism, status: :created
  end

  def update
    ActiveRecord::Base.transaction do 
      @organism.update!(organism_params)
      DrugOrganismMapping.where(organism_id: @organism.id).where.not(drug_id: params[:drugs]).each do |drug_organism|
        drug_organism.void("Removed from #{@organism.name} organism")
      end
      params[:drugs].each do |drug_id|
        DrugOrganismMapping.find_or_create_by!(drug_id: drug_id, organism_id: @organism.id)
      end
    end
    render json: @organism
  end

  def destroy
    @organism.void(params[:retired_reason])
    drug_organisms = DrugOrganismMapping.where(organism_id: @organism.id)
    drug_organisms.each do |drug_organism|
      drug_organism.void(params[:retired_reason])
    end
    render json: @organism
  end

  private

  def set_organism
    @organism = Organism.find(params[:id])
  end

  def organism_params
    params.require(:organism).permit(:name, :description)
  end

  def serialize_organism_drug(organism, drugs)
    {
      id: organism.id,
      name: organism.name,
      description: organism.description,
      drugs: drugs
    }
  end
end
