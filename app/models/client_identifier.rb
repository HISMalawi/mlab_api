class ClientIdentifier < VoidableRecord
  belongs_to :client_identifier_type
  belongs_to :client

  def as_json(options = {})
    super(options.merge(methods: %i[identifier_type]))
  end

  def identifier_type
    client_identifier_type.name 
  end
end
