# frozen_string_literal: true

class Person < VoidableRecord
  def self.search(search_term)
    where("CONCAT(first_name, ' ', middle_name, ' ', last_name) LIKE ?", "%#{search_term}%")
  end
end
