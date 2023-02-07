class Api::V1::DrugsController < ApplicationController
  before_action :set_drug, only: [:show, :update, :destroy]

  def index
    @drugs = Drug.all
    render json: @drugs
  end
  
  def show
    render json: @drug
  end

  def create
    @drug = Drug.new(drug_params)

    if @drug.save
      render json: @drug, status: :created, location: [:api, :v1, @drug]
    else
      render json: @drug.errors, status: :unprocessable_entity
    end
  end

  def update
    if @drug.update(drug_params)
      render json: @drug
    else
      render json: @drug.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @drug.destroy
  end

  private

  def set_drug
    @drug = Drug.find(params[:id])
  end

  def drug_params
    params.require(:drug).permit(:short_name, :name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
