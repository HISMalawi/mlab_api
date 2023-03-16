module PersonService
  class << self
    def create_person(first_name:, middle_name:, last_name:, sex:, date_of_birth:, birth_date_estimated:)
      Person.create(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated:birth_date_estimated, creator: User.current, created_date: Time.now, updated_date: Time.now)
    end

    def update_person(id:, first_name:, middle_name:, last_name:, sex:, date_of_birth:, birth_date_estimated:)
      Person.update(id: id, first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated:birth_date_estimated, creator: User.current)
    end
  end
end