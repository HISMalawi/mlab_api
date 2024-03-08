module Api
  module V1
    class SpecimenController < ApplicationController
      before_action :set_specimen, only: %i[show update destroy]

      def index
        @specimen = Specimen.all.order(:name)
        render json: @specimen
      end

      def show
        render json: @specimen
      end

      def specimen_test_type
        specimen = Specimen.find(params[:specimen_id])
        test_types = SpecimenTestTypeMapping.joins(:test_type).where(specimen_id: specimen.id)
        unless params[:department_id].blank?
          test_types = filter_test_types_by_department(params[:department_id],
                                                       test_types)
        end
        test_panel = TestTypePanelMapping.joins(:test_panel).joins(:test_type).where(
          test_type_id: test_types.pluck('specimen_test_type_mappings.test_type_id')
        ).pluck('test_panels.name')
        test_types = test_types.pluck('name') + test_panel
        render json: test_types.uniq.sort
      end

      def create
        @specimen = Specimen.create!(specimen_params)
        render json: @specimen, status: :created
      end

      def update
        @specimen.update!(specimen_params)
        render json: @specimen
      end

      def destroy
        @specimen.void(params[:retired_reason])
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def set_specimen
        @specimen = Specimen.find(params[:id])
      end

      def filter_test_types_by_department(department_id, test_types)
        department = Department.find(department_id)&.name
        unless department == 'Lab Reception'
          test_types = test_types.where("test_types.department_id = #{department_id}")
        end
        test_types
      end

      def specimen_params
        params.require(:speciman).permit(:name, :description)
      end
    end
  end
end
