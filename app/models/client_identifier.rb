class ClientIdentifier < ApplicationRecord
  belongs_to :client_identifier_type
  belongs_to :client
end
