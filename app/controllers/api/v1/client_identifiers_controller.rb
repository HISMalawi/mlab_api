class Api::V1::ClientIdentifiersController < ApplicationController
  before_action :set_client_identifier, only: [:show, :update, :destroy]

  def index
    @client_identifiers = ClientIdentifier.all
    render json: @client_identifiers
  end
  
  def show
    render json: @client_identifier
  end

  def create
    @client_identifier = ClientIdentifier.new(client_identifier_params)

    if @client_identifier.save
      render json: @client_identifier, status: :created, location: [:api, :v1, @client_identifier]
    else
      render json: @client_identifier.errors, status: :unprocessable_entity
    end
  end

  def update
    if @client_identifier.update(client_identifier_params)
      render json: @client_identifier
    else
      render json: @client_identifier.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @client_identifier.destroy
  end

  private

  def set_client_identifier
    @client_identifier = ClientIdentifier.find(params[:id])
  end

  def client_identifier_params
    params.require(:client_identifier).permit(:client_identifier_type_id, :value, :client_id, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date, :uuid)
  end
end
