class Api::V1::InstrumentsController < ApplicationController
  before_action :check_test_params, only: [:create, :update]

  def index
    page, page_size, search = pagination.values_at(:page, :page_size, :search)
    render json: InstrumentsService.find(page, page_size, search)
  end

  def show
    render json: Instrument.find(params[:id])
  end

  def create
    instrument = InstrumentsService.create_instrument(instrument_params, params[:test_types])
    render json: instrument, status: :created
  end

  def update
    instrument = Instrument.find(params[:id])
    instrument.update(instrument_params)
    render json: instrument, status: :ok
  end

  def destroy
    Instrument.find(params[:id]).void([:retired_reason])
    render json: MessageService::RECORD_DELETED, status: :ok
  end

  private

  def instrument_params
    params.permit(:name, :description, :ip_address, :hostname)
  end

  def check_test_params
    unless params.has_key?('test_types') && params[:test_types].is_a?(Array)
      raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for test_types"
    end
  end

  def pagination
    params.require([:page, :page_size])
    params.permit(:search)
    { page: params[:page], page_size: params[:page_size], search: params[:search] }
  end

  def user
    User.current.id
  end

  def supported_tests
    results = Instrument.joins(instrument_test_type_mapping: :test_type)
      .where(id: params[:id])
      .pluck("test_types.name")

    results.join(", ")
  end
end
