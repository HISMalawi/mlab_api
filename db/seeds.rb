Rails.logger = Logger.new(STDOUT)
# Client Identifier types
client_identifier_types = ['phone', 'physical_address', 'npid']
client_identifier_types.each do |identifier_type|
  if ClientIdentifierType.find_by_name(identifier_type).nil?
    Rails.logger.info("Loading client identifier type #{identifier_type}")
    ClientIdentifierType.create!(name: identifier_type)
  end
end