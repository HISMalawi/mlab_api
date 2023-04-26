class Api::V1::InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :update, :destroy]

  def index
    page, page_size, search = pagination.values_at(:page, :page_size, :search)
    if search.blank?
      data = Instrument.limit(page_size.to_i).offset(page.to_i - 1).all
    else
      data = Instrument.where("name like #{search}%").limit(page_size.to_i).offset(page.to_i - 1)
    end

    total = Instrument.count
    @instruments = {page: page.to_i,
                    page_size: page_size.to_i,
                    total: total.to_i,
                    data: data}

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
    @instrument.update(retired: true, retired_by: 1)
  end

  private

  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  def instrument_params
    params.require(:name)
    params.permit(:name, :description, :ip_address, :hostname, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end

  def pagination
    params.require([:page, :page_size])
    params.permit(:search)
    {page: params[:page], page_size: params[:page_size], search: params[:search]}
  end
end
