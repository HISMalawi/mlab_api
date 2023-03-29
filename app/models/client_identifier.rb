class ClientIdentifier < VoidableRecord
  belongs_to :client_identifier_type
  belongs_to :client
end
