class Api::V1::TestTypePanelMappingsController < ApplicationController
  before_action :set_test_type_panel_mapping, only: [:show, :update, :destroy]

  def index
    @test_type_panel_mappings = TestTypePanelMapping.all
    render json: @test_type_panel_mappings
  end
  
  def show
    render json: @test_type_panel_mapping
  end

  def create
    @test_type_panel_mapping = TestTypePanelMapping.new(test_type_panel_mapping_params)

    if @test_type_panel_mapping.save
      render json: @test_type_panel_mapping, status: :created, location: [:api, :v1, @test_type_panel_mapping]
    else
      render json: @test_type_panel_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_type_panel_mapping.update(test_type_panel_mapping_params)
      render json: @test_type_panel_mapping
    else
      render json: @test_type_panel_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_type_panel_mapping.destroy
  end

  private

  def set_test_type_panel_mapping
    @test_type_panel_mapping = TestTypePanelMapping.find(params[:id])
  end

  def test_type_panel_mapping_params
    params.require(:test_type_panel_mapping).permit(:test_type_id, :test_panel_id, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end
