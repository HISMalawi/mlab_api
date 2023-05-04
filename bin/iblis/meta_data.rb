Rails.logger = Logger.new(STDOUT)
User.current = User.first
ActiveRecord::Base.transaction do

  client_identifier_types = ['cellphone_number', 'occupation', 'current_district',
  'current_traditional_authority', 'current_village', 'home_village', 'home_district', 
  'home_traditional_authority', 'art_number', 'htn_number', 'npid', 'physical_address'
  ]

  client_identifier_types.each do |identifier_type|
    if ClientIdentifierType.find_by_name(identifier_type).nil?
      Rails.logger.info("Loading client identifier type #{identifier_type}")
      ClientIdentifierType.create!(name: identifier_type)
    end
  end

  # Load specimen
  specimes = Iblis.find_by_sql("SELECT * FROM specimen_types")
  specimes.each do | specimen |
    Rails.logger.info("=========Loading Specimen: #{specimen.name}===========")
    Specimen.create(name: specimen.name, description: specimen.description, retired: 0, creator: 1, created_date: specimen.created_at, updated_date: specimen.updated_at)
  end

   # Create Drugs and Organisms and map them
  IblisService::DrugOrganismService.create_drug
  IblisService::DrugOrganismService.create_organism
  IblisService::DrugOrganismService.drug_organism_mapping

  # Load test types
  test_types = Iblis.find_by_sql("SELECT tt.id, tt.name, tt.short_name, tc.name As dept, tt.created_at, tt.updated_at, tt.targetTAT FROM test_types tt INNER JOIN test_categories tc ON tc.id =tt.test_category_id")
  test_types.each do |test_type|
    department = Department.find_by_name(test_type.dept)
    Rails.logger.info("=========Loading test type: #{test_type.name}===========")
    mlap_test_type = TestType.create(name: test_type.name, short_name: test_type.short_name, department_id: department.id, retired: 0, expected_turn_around_time: test_type.targetTAT, creator: 1, created_date: test_type.created_at, updated_date: test_type.updated_at)
   IblisService::MeasureService.create_test_indicator(test_type.id, mlap_test_type.id)
   IblisService::DrugOrganismService.test_type_organism_mapping(test_type.id, mlap_test_type.id)
  end
  # Map test types with specimen
  testtypes_specimens = Iblis.find_by_sql("SELECT tt.name AS test_type, spt.name AS specimen FROM test_types tt
            INNER JOIN test_categories tc ON tc.id = tt.test_category_id INNER JOIN testtype_specimentypes ttspt ON ttspt.test_type_id = tt.id
          INNER JOIN specimen_types spt ON spt.id = ttspt.specimen_type_id")
  testtypes_specimens.each do |tt_sp|
    specimen = Specimen.find_by_name(tt_sp.specimen)
    test_type = TestType.find_by_name(tt_sp.test_type)
    Rails.logger.info("=========Mapping specimen: #{tt_sp.specimen} to test type: #{tt_sp.test_type}===========")
    SpecimenTestTypeMapping.create(specimen_id: specimen.id, test_type_id: test_type.id, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
  end
  # Load test panels
  panel_types = Iblis.find_by_sql("SELECT * FROM panel_types")
  panel_types.each do |panel_type|
    Rails.logger.info("=========Loading test panel: #{panel_type.name}===========")
    TestPanel.create(name: panel_type.name, short_name: panel_type.short_name, creator: 1,  created_date: panel_type.created_at, retired: 0, updated_date: panel_type.updated_at)
  end
  # Map test types to panels
  test_types_panels = Iblis.find_by_sql("SELECT tt.name AS test_type, pnt.name AS panel FROM panels pn INNER JOIN panel_types pnt ON pnt.id = pn.panel_type_id INNER JOIN test_types tt ON tt.id=pn.test_type_id")
  test_types_panels.each do |tt_panel|
    test_panel = TestPanel.find_by_name(tt_panel.panel)
    test_type = TestType.find_by_name(tt_panel.test_type)
    Rails.logger.info("=========Mapping panel: #{tt_panel.panel} to test type: #{tt_panel.test_type}===========")
    TestTypePanelMapping.create(test_panel_id: test_panel.id, test_type_id: test_type.id, creator: 1, voided: 0, created_date: Time.now, updated_date: Time.now)
  end 

  # Load statuses and status reasons
 IblisService::StatusService.create_test_status
 IblisService::StatusService.create_test_status_reason
end