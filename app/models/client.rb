# frozen_string_literal: true

# Client model
class Client < VoidableRecord
  belongs_to :person

  def self.find_by_npid(npid)
    client_identifier_type_id = ClientIdentifierType.find_by(name: 'npid')&.id
    client_identifier = ClientIdentifier.find_by(client_identifier_type_id:, value: npid)
    Client.find_by(id: client_identifier&.client_id)
  end
end
