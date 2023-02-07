class Api::V1::InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :update, :destroy]

  def index
    @instruments = Instrument.all
    render json: @instruments
  end
  
  def show
    render json: @instrument
  end

  def create
    @instrument = Instrument.new(instrument_params)

    if @instrument.save
      render json: @instrument, status: :created, location: [:api, :v1, @instrument]
    else
      render json: @instrument.errors, status: :unprocessable_entity
    end
  end

  def update
    if @instrument.update(instrument_params)
      render json: @instrument
    else
      render json: @instrument.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @instrument.destroy
  end

  private

  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  def instrument_params
    params.require(:instrument).permit(:name, :description, :ip_address, :hostname, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
