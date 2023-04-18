Rails.logger = Logger.new(STDOUT)
# Client Identifier types
client_identifier_types = ['cellphone_number', 'occupation', 'current_district',
  'current_traditional_authority', 'current_village', 'home_village', 'home_district', 
  'home_traditional_authority', 'art_number', 'htn_number'
]
client_identifier_types.each do |identifier_type|
  if ClientIdentifierType.find_by_name(identifier_type).nil?
    Rails.logger.info("Loading client identifier type #{identifier_type}")
    ClientIdentifierType.create!(name: identifier_type)
  end
end