module PersonService
  class << self
    def create_person(first_name:, middle_name:, last_name:, sex:, date_of_birth:, birth_date_estimated:)
      Person.create!(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated: birth_date_estimated)
    end

    def update_person(person:, first_name:, middle_name:, last_name:, sex:, date_of_birth:, birth_date_estimated:)
      person.update!(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated: birth_date_estimated)
    end
  end
end