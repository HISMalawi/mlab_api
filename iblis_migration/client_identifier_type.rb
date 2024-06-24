# frozen_string_literal: true

client_identifier_types = %w[current_village current_district current_traditional_authority physical_address phone npid]
client_identifier_types.each do |client_identifier_type|
  puts "Creating #{client_identifier_type} client identifier type"
  ClientIdentifierType.find_or_create_by(name: client_identifier_type)
end
