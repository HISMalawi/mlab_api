Rails.logger = Logger.new(STDOUT)
User.current = User.first

def insert_to_db values
    encounter_type = EncounterType.find_or_create_by(name: values[:name])
    encounter_type.update!(values)
    encounter_type.save!
end

ActiveRecord::Base.transaction do   
    #also known as visit types in iblis
    Rails.logger.info("=========Creating Encounter Types===========")
    visit_types = Iblis.find_by_sql("SELECT * FROM visit_types")
    transformed = visit_types.map { |v| {name: v.name, description: v.name, creator: User.current.id,  created_date: Date.today, updated_date: Date.today}}
    transformed.collect { |v| insert_to_db v }
    Rails.logger.info("=========Encounter Types Created===========")
end
