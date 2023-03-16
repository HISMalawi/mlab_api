class Api::V1::OrganismsController < ApplicationController
  before_action :set_organism, only: [:show, :update, :destroy]

  def index
    @organisms = Organism.where(retired: 0)
    render json: @organisms
  end
  
  def show
    drugs = DrugOrganismMapping.joins(:drug).where(organism_id: 1, retired: 0).select('drugs.id, drugs.name, drugs.short_name')
    render json: {organism: @organism, drugs: drugs}, status: :ok
  end

  def create
    debugger
    @organism = Organism.new(organism_params)
    if @organism.save
      if !organism_params[:drugs].empty?
        organism_params[:drugs].each do |drug|
          DrugOrganismMapping.create(drug_id: drug, organism_id: @organism.id, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        end
      end
      render json: @organism, status: :created, location: [:api, :v1, @organism]
    else
      render json: @organism.errors, status: :unprocessable_entity
    end
  end

  def update
    if @organism.update(name: organism_params[:name], description: organism_params[:description],  updated_date: Time.now)
      drug_organisms_ids = DrugOrganismMapping.where(organism_id: @organism.id, retired: 0).pluck('id')
      new_drugs_to_be_mapped = organism_params[:drugs] - drug_organisms_ids
      drugs_to_be_removed = drug_organisms_ids - organism_params[:drugs]
      if organism_params[:drugs].sort == drug_organisms_ids.sort
        render json: @organism && return
      elsif !new_drugs_to_be_mapped.empty?
        new_drugs_to_be_mapped.each do | drug |
          DrugOrganismMapping.create(drug_id: drug, organism_id: @organism.id, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        end
      elsif !drugs_to_be_removed.empty?
        drugs_to_be_removed.each do | drug |
          drug_organism = DrugOrganismMapping.update(drug_id: drug, organism_id: @organism.id)
          drug_organism.update(retired: 1, retired_by: User.current.id, retired_reason: 'Removed from organism', retired_date: Time.now, updated_date: Time.now)
        end
      end
      render json: @organism
    else
      render json: @organism.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @organism.update(retired: 1, retired_by: User.current.id, retired_reason: organism_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
      render json: @organism, status: :ok
    else
      render json: @organism.errors, status: :unprocessable_entity
   end
  end

  private

  def set_organism
    @organism = Organism.find(params[:id])
  end

  def organism_params
    params.permit(:name, :description, :drugs)
  end
end
