LOGGER = Logger.new(STDOUT)
User.current = User.first

def insert_to_db(model, values)
  begin
    item = model.new(values)
    item.save!
  rescue ActiveRecord::RecordInvalid => e
    LOGGER.error("=========Error: Failed to create #{model} with values #{values}===========")
    LOGGER.error("=========Error: #{e.message}===========")
  rescue ActiveRecord::RecordNotUnique => e
    LOGGER.error("=========Error: Failed to create #{model} with values #{values}===========")
    LOGGER.error("=========Error: #{e.message}===========")
  end
end

ActiveRecord::Base.transaction do
  LOGGER.info("=========Creating Facilities===========")

  data = Iblis.find_by_sql("SELECT * FROM facilities")
  mapped = data.map { |v| {id: v.id, name: v.name, creator: User.current.id, created_date: Date.today, updated_date: Date.today } }
 
  mapped.collect { |v| insert_to_db Facility, v }

  LOGGER.info("=========Facilities Created===========")

  LOGGER.info("=========Creating Facility Sections===========")

  sections = Iblis.find_by_sql("SELECT * FROM wards")
  mapped_sections = sections.map { |v| { id: v.id, name: v.name, creator: User.current.id, created_date: Date.today, updated_date: Date.today } }
  puts mapped_sections
  mapped_sections.collect { |v| insert_to_db FacilitySection, v }

  LOGGER.info("=========Facility Sections Created===========")

  LOGGER.info("=========Mapping Encounter Types to Facility Sections===========")

  visittype_wards = Iblis.find_by_sql("SELECT * FROM visittype_wards")
  visittype_wards_mapped = visittype_wards.map { |v| { facility_section_id: v.ward_id, encounter_type_id: v.visit_type_id, creator: User.current.id, created_date: Date.today, updated_date: Date.today } }

  visittype_wards_mapped.each do |v|
    LOGGER.info("=========Mapping Encounter Type #{v[:encounter_type_id]} to Facility Section #{v[:facility_section_id]}===========")
    begin
      item = EncounterTypeFacilitySectionMapping.find_or_create_by(facility_section_id: v[:facility_section_id], encounter_type_id: v[:encounter_type_id]) rescue nil
      next if item.blank?
      item.update!(v)
      item.save!
    rescue => exception
      puts exception
    end
  end
  LOGGER.info("=========Encounter Types Mapped to Facility Sections===========")


  Global.find_or_create_by(
      name: Facility.first.name,
      address: "P.O Box 34, Lilongwe",
      phone: "+265323443",
      code: 'KCH'
  )
end
