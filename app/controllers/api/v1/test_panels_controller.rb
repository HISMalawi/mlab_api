class Api::V1::TestPanelsController < ApplicationController
  before_action :set_test_panel, only: [:show, :update, :destroy]

  def index
    @test_panels = TestPanel.all
    render json: @test_panels
  end
  
  def show
    test_types = TestTypePanelMapping.where(test_panel_id: @test_panel.id, voided: 0).joins(:test_type).select('test_types.id, test_types.name, test_types.short_name')
    render json: serialize(@test_panel, test_types), status: :ok
  end

  def create
    @test_panel = TestPanel.new(name: test_panel_params[:name], short_name: test_panel_params[:short_name], description: test_panel_params[:description], retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @test_panel.save
      if !test_panel_params[:test_types].empty?
        test_panel_params[:test_types].each do |test_type|
          TestTypePanelMapping.create(test_type_id: test_type, test_panel_id: @test_panel.id, voided: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
        end
      end
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
    params
  end

  def serialize(test_panel, test_types)
    {
      id: test_panel.id,
      name: test_panel.name,
      short_name: test_panel.short_name,
      test_types: test_types
    }
  end
end
