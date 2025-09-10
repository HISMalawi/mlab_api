# frozen_string_literal: true

# Module test catalog
module TestCatalog
  # Module specime service
  module SpecimenService
    class << self
      def specimen(department_id: nil)
        specimen = Specimen.order(:preferred_name)
        not_specified = Specimen.find_by(name: 'not_Specified')
        return specimen.where.not(id: not_specified&.id) if department_id.blank?

        department = Department.find_by(id: department_id)
        return specimen if department.nil? || department.name == 'Lab Reception'

        specimen_ids = SpecimenTestTypeMapping.joins(:test_type)
                                              .where(test_types: { department_id: department.id })
                                              .select(:specimen_id)
                                              .distinct
        specimen.where(id: specimen_ids).where.not(id: not_specified&.id)
      end

      def specimen_test_type(specimen_id, department_id, sex)
        test_types = filter_test_types_by_specimen(specimen_id)
        test_types = filter_test_types_by_department(department_id, test_types) unless department_id.blank?
        test_types = filter_test_types_by_sex(sex, test_types)
        test_types = TestType.where(id: test_types.pluck('specimen_test_type_mappings.test_type_id'))
        test_types = test_types.where(can_be_ordered: true)
        test_types_display_column = GlobalService.full_name_display? ? 'test_types.name' : 'test_types.preferred_name'
        test_panel_display_column = GlobalService.full_name_display? ? 'test_panels.name' : 'COALESCE(test_panels.preferred_name, test_panels.name)'
        test_type_ids = test_types.pluck(:id)
        test_panel = TestTypePanelMapping.joins(:test_panel, :test_type)
                                         .where(test_type_id: test_type_ids)
                                         .pluck(Arel.sql(test_panel_display_column.to_s))
        test_names = test_types.pluck(Arel.sql(test_types_display_column.to_s))
        (test_names + test_panel).uniq.sort
      end

      def filter_test_types_by_department(department_id, test_types)
        department = Department.find(department_id)&.name
        return test_types if department == 'Lab Reception'

        test_types.where("test_types.department_id = #{department_id}")
      end

      def filter_test_types_by_sex(sex, test_types)
        return test_types if sex.blank?

        test_types.where("test_types.sex = '#{sex}' OR test_types.sex = 'Both'")
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
