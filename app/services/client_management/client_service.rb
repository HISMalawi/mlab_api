# frozen_string_literal: true

require 'bantu_soundex'

# Client management module
module ClientManagement
  # Client service module
  module ClientService
    class << self
      def get_client(client_id)
        client = Client.find(client_id)
        person = Person.find(client.person.id)
        client_identifiers = ClientIdentifier.joins(:client_identifier_type).where(client_id: client_id)
          .select('client_identifiers.id, client_identifier_types.name, client_identifiers.value')
        serialize_client(client, person, client_identifiers)
      end

      def create_client(params, identifiers)
        @client = params[:client][:uuid].blank? ? nil : Client.find_by_uuid(params[:client][:uuid])
        middle_name = params[:person][:middle_name].blank? || params[:person][:middle_name].downcase == 'unknown' ? '' : params[:person][:middle_name]
        lab_location_id = params[:lab_location].present? ? params[:lab_location].to_i : 1
        if @client.nil?
          ActiveRecord::Base.transaction do
            person = Person.create!(
              first_name: params[:person][:first_name],
              middle_name:,
              last_name: params[:person][:last_name],
              sex: params[:person][:sex],
              date_of_birth: params[:person][:date_of_birth],
              birth_date_estimated: params[:person][:birth_date_estimated],
              first_name_soundex: params[:person][:first_name].soundex,
              last_name_soundex: params[:person][:last_name].soundex
            )
            uuid =  params[:client][:uuid]
            @client = Client.create!(person_id: person.id, uuid:, lab_location_id:)
            create_client_identifier(identifiers, @client.id)
          end
        end
        @client
      end

      def create_client_identifier(identifiers, client_id)
        client_identifier_types = identifiers.blank? ? [] : identifiers.keys
        if client_identifier_types.length > 1
          client_identifier_types.each do |identifier_type|
            client_identifier_type = ClientIdentifierType.find_by_name(identifier_type)
            unless (client_identifier_type.nil? || identifiers[identifier_type].blank?)
              ClientIdentifier.create!(client_identifier_type_id: client_identifier_type.id, client_id: client_id, value: identifiers[identifier_type])
            end
          end
        end
      end

      def update_client(client, params, identifier_params)
        ActiveRecord::Base.transaction do
          person = client.person
          person.update!(params[:person])
          person.update!(first_name_soundex: person.first_name.soundex, last_name_soundex: person.last_name.soundex)
          identifier_params[:client_identifiers].each do |identifier|
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

      def search_client(client_name, per_page)
        if client_name.to_i.zero?
          people = Person.search(client_name)
          @client = Client.where(person_id: people).order(id: :desc).page.per(per_page)
        else
          @client = Client.where(id: client_name).order(id: :desc).page.per(per_page)
        end
        @client
      end

      def search_client_by_name_and_gender(first_name, last_name, gender)
        people = Person.search_by_name_and_gender(first_name, last_name, gender)
        Client.joins(:person).where(person_id: people).limit(10)
      end

      def serialize_client(client, person, client_identifiers)
        client_hash = {
          source: 'local',
          client_id: client.id,
          first_name: person.first_name,
          middle_name: person.middle_name.nil? ? '' : person.middle_name,
          last_name: person.last_name,
          sex: person.sex,
          date_of_birth: person.date_of_birth,
          birth_date_estimated: person.birth_date_estimated,
          uuid: client.uuid,
          created_at: client.created_date
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
        client_all
      end

    end
  end
end
