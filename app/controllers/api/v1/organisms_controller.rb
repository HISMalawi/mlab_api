class Api::V1::OrganismsController < ApplicationController
  before_action :set_organism, only: [:show, :update, :destroy]

  def index
    @organisms = Organism.all
    render json: @organisms
  end
  
  def show
    render json: @organism
  end

  def create
    @organism = Organism.new(organism_params)

    if @organism.save
      render json: @organism, status: :created, location: [:api, :v1, @organism]
    else
      render json: @organism.errors, status: :unprocessable_entity
    end
  end

  def update
    if @organism.update(organism_params)
      render json: @organism
    else
      render json: @organism.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @organism.destroy
  end

  private

  def set_organism
    @organism = Organism.find(params[:id])
  end

  def organism_params
    params.require(:organism).permit(:name, :description, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
