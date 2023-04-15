# frozen_string_literal: true

class Person < VoidableRecord

  def self.search(search_term)
    search_term = search_term.gsub(/\s+/, '')
    where("CONCAT(first_name, middle_name, last_name) LIKE '%#{search_term}%' 
      OR CONCAT(last_name, middle_name, first_name) LIKE '%#{search_term}%'"
    )
  end

  def self.search_by_name_and_gender(first_name, last_name, gender)
    where(first_name: first_name, last_name: last_name, sex: gender)
  end
end
