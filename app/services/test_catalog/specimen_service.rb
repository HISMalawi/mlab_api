# frozen_string_literal: true

# Module test catalog
module TestCatalog
  # Module specime service
  module SpecimenService
    class << self
      def specimen(department_id: nil)
        dpt = Department.where(id: department_id).first
        department_name = dpt.nil? ? 'Lab Reception' : dpt.name
        test_types = department_name == 'Lab Reception' ? TestType.all : TestType.where(department_id: dpt.id)
        specimen_test_type_mappings = SpecimenTestTypeMapping.where(test_type_id: test_types.pluck(:id))
        specimen_ids = specimen_test_type_mappings.pluck(:specimen_id).uniq
        Specimen.where(id: specimen_ids).order(:name)
      end

      def specimen_test_type(specimen_id, department_id)
        test_types = filter_test_types_by_specimen(specimen_id)
        test_types = filter_test_types_by_department(department_id, test_types) unless department_id.blank?

        test_panel = TestTypePanelMapping.joins(:test_panel, :test_type)
                                         .where(
                                           test_type_id: test_types.pluck('specimen_test_type_mappings.test_type_id')
                                         )
                                         .pluck('test_panels.name')
        (test_types.pluck('name') + test_panel).uniq.sort
      end

      def filter_test_types_by_department(department_id, test_types)
        department = Department.find(department_id)&.name
        return test_types if department == 'Lab Reception'

        test_types.where("test_types.department_id = #{department_id}")
      end

      def filter_test_types_by_specimen(specimen_id)
        SpecimenTestTypeMapping.joins(:test_type)
                               .where(specimen_id:)
                               .where.not("test_types.name LIKE '%(Paed%'")
                               .where.not("test_types.name LIKE '%(cancer%'")
      end
    end
  end
end
