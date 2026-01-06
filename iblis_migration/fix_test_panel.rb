# frozen_string_literal: true

panels = ['CSF Analysis',
          'Urine analysis',
          'Sterile Fluid Full Analysis',
          'Thyroid Function Tests',
          'Cryptococcal Test Panel',
          'Stool Culture',
          'Coagulation Factors',
          'Coagulation Factor 50/50 Mixing Studies',
          'Diabetes Panel',
          'BioMarkers']

test_panels = TestPanel.where.not(name: panels)
test_panels.each do |panel|
  if panel.name == 'Urinalysis'
    Test.where(test_panel_id: panel.id).update_all(test_panel_id: TestPanel.find_by(name: 'Urine analysis').id)
  end
  if panel.name == 'Sterile Fluid Analysis'
    Test.where(test_panel_id: panel.id).update_all(test_panel_id: TestPanel.find_by(name: 'Sterile Fluid Full Analysis').id)
  end
  puts "Voiding panel #{panel.name}"
  panel.void('No longer used')
end
