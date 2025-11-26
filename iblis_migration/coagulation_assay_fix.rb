# frozen_string_literal: true

coagulation_assay = TestType.where(name: 'Coagulation Assay').first
coagulation_assay_panel = TestPanel.where(name: 'Coagulation Factors').first
User.current = User.first

exit if coagulation_assay.blank?

coagulation_assays_indicators = TestIndicator.where(id: TestTypeTestIndicator.where(test_types_id: coagulation_assay.id).pluck(:test_indicators_id))
ActiveRecord::Base.transaction do
  coagulation_assays_indicators.each do |indicator|
    test_results = TestResult.where(test_indicator_id: indicator.id)
    test_results.each do |test_result|
      next if test_result.blank? || test_result.value.blank? || test_result.value&.downcase == 'nil'

      puts "Mapping the result #{test_result.value} to the correct test type"
      test_type = TestType.find_by(nlims_code: indicator.nlims_code)
      next if test_type.blank?

      lab_test = Test.unscoped.find_by(id: test_result.test_id)
      next if lab_test.blank?

      new_test = lab_test.dup
      new_test.test_type_id = test_type.id
      new_test.test_panel_id = coagulation_assay_panel.id

      if new_test.save!
        puts "Created new test #{new_test.id} (from old test #{lab_test.id}) with new test_type_id #{test_type.id}"

        new_test.update(created_date: lab_test.created_date, updated_date: lab_test.updated_date)
        # Update the test_result to point to the new test
        test_result.update(test_id: new_test.id)
        TestStatus.where(test_id: lab_test.id).each do |test_status|
          test_status.update(test_id: new_test.id)
        end
      else
        puts "Failed to create new test for test_result #{test_result.id}: #{new_test.errors.full_messages.join(', ')}"
      end
    end
  end

  # Void the tests with coagulation_assays test type
  tests = Test.where(test_type_id: coagulation_assay.id)
  tests.each do |test|
    test.void('No longer used')
  end
end
