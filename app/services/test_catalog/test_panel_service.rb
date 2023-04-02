module TestCatalog
  module TestPanelService
    class << self
      
      def create_panel(test_panel_params, params)
        ActiveRecord::Base.transaction do
          @test_panel = TestPanel.create!(test_panel_params)
          params[:test_types].each do |test_type|
            TestTypePanelMapping.create!(test_type_id: test_type, test_panel_id: @test_panel.id)
          end
        end
        @test_panel
      end

      def show_panel(test_panel)
        test_types = TestTypePanelMapping.where(test_panel_id: test_panel.id).joins(:test_type)
                    .select('test_types.id, test_types.name, test_types.short_name')
        serialize(test_panel, test_types)
      end

      def update_panel(test_panel, test_panel_params, test_types)
        ActiveRecord::Base.transaction do 
          test_panel.update!(test_panel_params)
          TestTypePanelMapping.where(test_panel_id: test_panel.id).where.not(test_type_id: test_types).each do |test_type_panel_mapping|
            test_type_panel_mapping.void('Remove from TestTypePanel')
          end
          test_types.each do |test_type|
            TestTypePanelMapping.find_or_create_by(test_panel_id: test_panel.id, test_type_id: test_type)
          end
          test_panel
        end
      end
      
      def void_panel(test_panel, reason)
        unless reason
          raise ActionController::ParameterMissing, " retired_reason"
        end
        test_panel.void(reason)
        TestTypePanelMapping.where(test_panel_id: test_panel.id).each do |test_type_panel|
          test_type_panel.void(reason)
        end
        test_panel
      end

      def serialize(test_panel, test_types)
        {
          id: test_panel.id,
          name: test_panel.name,
          short_name: test_panel.short_name,
          description: test_panel.description,
          test_types: test_types
        }
      end

    end
  end
end