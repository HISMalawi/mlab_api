class ClientIdentifier < VoidableRecord
  belongs_to :client_identifier_type
  belongs_to :client

  def as_json(options = {})
    super(options.merge(methods: %i[identifier_type]))
  end

  def identifier_type
    client_identifier_type.name
  end

  def self.search_identifier_value(value, identifier_type_id)
    where('value LIKE ?', "#{value}%")
      .where(client_identifier_type_id: identifier_type_id)
      .select('distinct value')
      .limit(10)
      .map(&:value)
  end
end
