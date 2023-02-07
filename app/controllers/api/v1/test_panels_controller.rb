class Api::V1::TestPanelsController < ApplicationController
  before_action :set_test_panel, only: [:show, :update, :destroy]

  def index
    @test_panels = TestPanel.all
    render json: @test_panels
  end
  
  def show
    render json: @test_panel
  end

  def create
    @test_panel = TestPanel.new(test_panel_params)

    if @test_panel.save
      render json: @test_panel, status: :created, location: [:api, :v1, @test_panel]
    else
      render json: @test_panel.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_panel.update(test_panel_params)
      render json: @test_panel
    else
      render json: @test_panel.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_panel.destroy
  end

  private

  def set_test_panel
    @test_panel = TestPanel.find(params[:id])
  end

  def test_panel_params
    params.require(:test_panel).permit(:name, :description, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
