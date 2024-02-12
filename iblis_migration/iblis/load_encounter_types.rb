Rails.logger = Logger.new(STDOUT)
User.current = User.first

def insert_to_db(values)
  begin
    encounter_type = EncounterType.new(values)
    encounter_type.save!
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("=========Error: Failed to create with values #{values}===========")
    Rails.logger.info("=========Error: #{e.message}===========")
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.info("=========Error: Failed to createwith values #{values}===========")
    Rails.logger.info("=========Error: #{e.message}===========")
  end
end

ActiveRecord::Base.transaction do
  #also known as visit types in iblis
  Rails.logger.info("=========Creating Encounter Types===========")
  visit_types = Iblis.find_by_sql("SELECT * FROM visit_types")
  transformed = visit_types.map { |v| { id: v.id, name: v.name, description: v.name, creator: User.current.id, created_date: Date.today, updated_date: Date.today } }
  transformed.collect { |v| insert_to_db v }
  Rails.logger.info("=========Encounter Types Created===========")
end
