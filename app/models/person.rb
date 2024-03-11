# frozen_string_literal: true

require 'bantu_soundex'

# person model
class Person < VoidableRecord
  def self.search(search_term)
    search_term = search_term.gsub(/\s+/, '')
    where("CONCAT(first_name, middle_name, last_name) LIKE '%#{search_term}%'
      OR CONCAT(last_name, middle_name, first_name) LIKE '%#{search_term}%'")
  end

  def self.search_by_name_and_gender(first_name, last_name, gender)
    where(first_name_soundex: first_name.soundex, last_name_soundex: last_name.soundex, sex: gender)
  end

  def fullname
    "#{first_name} #{middle_name} #{last_name}"
  end

  def self.search_by_first_name(first_name)
    where("first_name LIKE '#{first_name}%'").select('distinct first_name').limit(10).map(&:first_name)
  end

  def self.search_by_last_name(last_name)
    where("last_name LIKE '#{last_name}%'").select('distinct last_name').limit(10).map(&:last_name)
  end
end
