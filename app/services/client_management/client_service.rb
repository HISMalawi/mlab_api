module ClientManagement
  module ClientService
    class << self

      def get_client(client_id)
        client = Client.find(client_id)
        person = Person.find(client.person.id)
        client_identifiers = ClientIdentifier.joins(:client_identifier_type).where(client_id: client_id)
        .select('client_identifiers.id, client_identifier_types.name, client_identifiers.value')
        serialize_client(client, person, client_identifiers)
      end

      def create_client(params)
        ActiveRecord::Base.transaction do
          person = Person.create!(params[:person])
          uuid =  params[:client][:uuid].blank? ? SecureRandom.uuid << "#{person.id}" : params[:client][:uuid]
          client = Client.create!(person_id: person.id, uuid: uuid)
          params[:client_identifiers].each do |identifier|
            client_identifier_type = ClientIdentifierType.find_by_name(identifier[:type])
            unless (client_identifier_type.nil? || identifier[:value].blank?)
              ClientIdentifier.create!(client_identifier_type_id: client_identifier_type.id, client_id: client.id, value: identifier[:value])
            end
          end
          client
        end
      end

      def update_client(client, params)
        ActiveRecord::Base.transaction do
          person = client.person
          person.update!(params[:person])
          params[:client_identifiers].each do |identifier|
            client_identifier_type = ClientIdentifierType.find_by_name(identifier[:type])
            unless client_identifier_type.nil?
              client_identifier = ClientIdentifier.find_or_initialize_by(client_identifier_type_id: client_identifier_type.id, client_id: client.id)
              client_identifier.update!(value: identifier[:value])
            end
          end
        end
      end

      def void_client(client, reason)
        client.void(reason)
        user = User.where(person_id: client.person.id).first
        if user.nil?
            client.person.void(reason)
        end
        client_identifiers = ClientIdentifier.where(client_id: client.id)
        client_identifiers.each do | client_identifier|
          client_identifier.void(reason)
        end
      end

      def serialize_client(client, person, client_identifiers)
        client_hash = {
          client_id: client.id,
          first_name: person.first_name,
          last_name: person.last_name,
          middle_name: person.middle_name,
          sex: person.sex,
          date_of_birth: person.date_of_birth,
          birth_date_estimated: person.birth_date_estimated,
          uuid: client.uuid
        }
        client_identifiers.each do | client_identifier|
          client_hash["#{client_identifier.name}"] = client_identifier.value
        end
        client_hash
      end

      def serialize_clients(clients)
        client_all = []
        clients.each do |client|
          client_all << get_client(client.id)
        end
        client_all.sort_by! { |e| [e['last_name'], e['first_name']] }.reverse
      end

    end
  end
end