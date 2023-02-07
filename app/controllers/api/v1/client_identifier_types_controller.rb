class Api::V1::ClientIdentifierTypesController < ApplicationController
  before_action :set_client_identifier_type, only: [:show, :update, :destroy]

  def index
    @client_identifier_types = ClientIdentifierType.all
    render json: @client_identifier_types
  end
  
  def show
    render json: @client_identifier_type
  end

  def create
    @client_identifier_type = ClientIdentifierType.new(client_identifier_type_params)

    if @client_identifier_type.save
      render json: @client_identifier_type, status: :created, location: [:api, :v1, @client_identifier_type]
    else
      render json: @client_identifier_type.errors, status: :unprocessable_entity
    end
  end

  def update
    if @client_identifier_type.update(client_identifier_type_params)
      render json: @client_identifier_type
    else
      render json: @client_identifier_type.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @client_identifier_type.destroy
  end

  private

  def set_client_identifier_type
    @client_identifier_type = ClientIdentifierType.find(params[:id])
  end

  def client_identifier_type_params
    params.require(:client_identifier_type).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
