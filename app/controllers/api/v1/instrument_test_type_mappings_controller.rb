class Api::V1::InstrumentTestTypeMappingsController < ApplicationController
  before_action :set_instrument_test_type_mapping, only: [:show, :update, :destroy]

  def index
    @instrument_test_type_mappings = InstrumentTestTypeMapping.all
    render json: @instrument_test_type_mappings
  end
  
  def show
    render json: @instrument_test_type_mapping
  end

  def create
    @instrument_test_type_mapping = InstrumentTestTypeMapping.new(instrument_test_type_mapping_params)

    if @instrument_test_type_mapping.save
      render json: @instrument_test_type_mapping, status: :created, location: [:api, :v1, @instrument_test_type_mapping]
    else
      render json: @instrument_test_type_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @instrument_test_type_mapping.update(instrument_test_type_mapping_params)
      render json: @instrument_test_type_mapping
    else
      render json: @instrument_test_type_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @instrument_test_type_mapping.destroy
  end

  private

  def set_instrument_test_type_mapping
    @instrument_test_type_mapping = InstrumentTestTypeMapping.find(params[:id])
  end

  def instrument_test_type_mapping_params
    params.require(:instrument_test_type_mapping).permit(:instrument_id, :test_type_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
