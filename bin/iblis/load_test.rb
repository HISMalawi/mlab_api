Rails.logger = Logger.new(STDOUT)
facility = Facility.create(name: 'test_facility')
creator = 1

User.current = User.find(creator)

facility_section = FacilitySection.create(name: 'test_facility_section')
priority = Priority.create(name: 'test_priority')

# clients
orders = Iblis.find_by_sql("SELECT 

  sp.accession_number, sp.tracking_number, tt.name as t_name, p.name, p.dob, st.name as sp_name, v.visit_type
    FROM
      specimens sp
          INNER JOIN
      tests t ON sp.id = t.specimen_id
          INNER JOIN
      visits v on v.id=t.visit_id
          INNER JOIN
      patients p on v.patient_id = p.id
          INNER JOIN
      test_types tt ON tt.id = t.test_type_id
      inner join specimen_types st on st.id=sp.specimen_type_id order by sp.id limit 1000
    ")

orders.each do |order_|
  name = order_.name.split(' ')
  if name.length > 2
    first_name = name[0]
    middle_name = name[1]
    last_name = name[2]
  else
    first_name = name[0]
    middle_name = ''
    last_name = name[1]
  end
  p = Person.where(first_name: , middle_name: , last_name: , date_of_birth: order_.dob).pluck('id').first
  client = Client.where(person_id: p).first
  encouter = Encounter.create(client_id: client.id, facility_id: facility.id, facility_section_id: facility_section.id, 
    destination_id: facility.id, start_date: Time.now
    destination_id: facility.id, start_date: Time.now, encounter_type_id: EncounterType.find_by_name(order_.visit_type&.strip).id
  )
  
  order = Order.find_or_create_by(encounter_id: encouter.id, priority_id: priority.id, accession_number: order_.accession_number, 
    tracking_number: order_.tracking_number)
  
  specimen = Specimen.find_by_name(order_.sp_name)
  
  test_type = TestType.find_by_name(order_.t_name)

  Rails.logger.info("Loading Test")
  
  Test.create(specimen_id: specimen.id, test_type_id: test_type.id, order_id: order.id)
end
