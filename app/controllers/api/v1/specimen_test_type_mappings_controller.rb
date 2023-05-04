class Api::V1::SpecimenTestTypeMappingsController < ApplicationController
  before_action :set_specimen_test_type_mapping, only: [:show, :update, :destroy]

  def index
    @specimen_test_type_mappings = paginate(SpecimenTestTypeMapping.joins(:specimen, :test_type)
                                                          .select('specimen_test_type_mappings.id,
                                                          specimen_test_type_mappings.test_type_id,
                                                          specimen_test_type_mappings.specimen_id,  
                                                          specimen_test_type_mappings.life_span,
                                                          specimen_test_type_mappings.life_span_units,
                                                          specimen.name specimen_name, test_types.name test_type'))
    render json: @specimen_test_type_mappings
  end
  
  def show
    render json: @specimen_test_type_mapping
  end

  def create
    @specimen_test_type_mapping = SpecimenTestTypeMapping.new(specimen_test_type_mapping_params)

    if @specimen_test_type_mapping.save
      render json: @specimen_test_type_mapping, status: :created, location: [:api, :v1, @specimen_test_type_mapping]
    else
      render json: @specimen_test_type_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @specimen_test_type_mapping.update(specimen_test_type_mapping_params)
      render json: @specimen_test_type_mapping
    else
      render json: @specimen_test_type_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @specimen_test_type_mapping.destroy
  end

  private

  def set_specimen_test_type_mapping
    @specimen_test_type_mapping = SpecimenTestTypeMapping.find(params[:id])
  end

  def specimen_test_type_mapping_params
    params.require([:life_span, :life_span_units])
    params.require(:specimen_test_type_mapping).permit(:life_span,:life_span_units, :specimen_id, :test_type_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
