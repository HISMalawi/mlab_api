# frozen_string_literal: true

# Module test catalog
module TestCatalog
  # Module specime service
  module SpecimenService
    class << self
      def specimen(department_id: nil)
        reception_department_id = Department.find_by(name: 'Lab Reception')&.id
        test_types = TestType.where('nlims_code IS NOT NULL').where(can_be_ordered: true).where.not(disabled: true)
        specimens = SpecimenTestTypeMapping.joins(:test_type)
                                           .where(test_types: { id: test_types.pluck(:id) })
        if department_id.present? && department_id&.to_i != reception_department_id
          specimens = specimens.where(test_types: { department_id: department_id })
        end
        specimen_ids = specimens.select(:specimen_id).distinct
        specimen = Specimen.excluding_not_specified.where(id: specimen_ids).where('nlims_code IS NOT NULL')
        GlobalService.full_name_display? ? specimen.order(:name) : specimen.order(:preferred_name)
      end

      def specimen_test_type(specimen_id, department_id, sex)
        test_types = filter_test_types_by_specimen(specimen_id)
        test_types = filter_test_types_by_department(department_id, test_types) unless department_id.blank?
        test_types = filter_test_types_by_sex(sex, test_types)
        test_types = TestType.where(id: test_types.pluck('specimen_test_type_mappings.test_type_id'))
        test_types = test_types.where(can_be_ordered: true, disabled: false)

        # Return structured data with test types and their attributes
        test_types_with_attributes = test_types.map do |tt|
          # Get attributes for this test type
          test_type_attributes = TestTypeAttribute.root_attributes_for_test_type(tt.id)
          attributes_data = test_type_attributes.map { |tta| tta.as_json(include_children: true) }

          {
            id: tt.id,
            name: GlobalService.full_name_display? ? tt.name : (tt.preferred_name || tt.name),
            is_panel: false,
            attributes: attributes_data
          }
        end

        # Get test panels
        test_type_ids = test_types.pluck(:id)
        test_panels = TestPanel.joins(:test_type_panel_mappings)
                               .where(test_type_panel_mappings: { test_type_id: test_type_ids })
                               .distinct

        test_panels_data = test_panels.map do |tp|
          {
            id: tp.id,
            name: GlobalService.full_name_display? ? tp.name : (tp.preferred_name || tp.name),
            is_panel: true,
            attributes: [] # Panels don't have attributes directly
          }
        end

        (test_types_with_attributes + test_panels_data).sort_by { |item| item[:name] }
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
