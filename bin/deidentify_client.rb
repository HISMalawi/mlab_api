# frozen_string_literal: true

require 'csv'

def deidentify_people
  CSV.open("deidentified_people_#{Time.now}.csv", 'w') do |csv|
    csv << %w[id First_Name Last_Name]
    Person.find_each do |person|
      deidentified_name = "Anonymous #{person.id}"
      csv << [person.id, person.first_name, person.last_name, deidentified_name]
      puts "Deidentifying #{deidentified_name}"
      person.update(first_name: 'Anonymous', last_name: person.id)
    end
  end
end

if ARGV.include?('--dev')
  deidentify_people
  puts 'Patient de-identification completed.'
else
  puts 'No --dev argument provided. Patient de-identification skipped.'
end

