# frozen_string_literal: true

require 'bantu_soundex'

# Client management module
module ClientManagement
  # Client service module
  # rubocop:disable Metrics/ModuleLength
  module ClientService
    # Client Service class
    # rubocop:disable Metrics/ClassLength
    class << self
      def client(client_id)
        client = Client.find(client_id)
        person = Person.find(client.person.id)
        client_identifiers = client_identifiers(client_id)
        serialize_client(client, person, client_identifiers)
      end

      # rubocop:disable Metrics/AbcSize
      def create_client(params, identifiers)
        client = find_or_initialize_client(params[:client][:uuid])
        middle_name = sanitize_middle_name(params[:person][:middle_name])
        lab_location_id = params[:lab_location].present? ? params[:lab_location].to_i : 1
        return unless client.new_record?

        ActiveRecord::Base.transaction do
          person = create_person(params[:person], middle_name)
          client = create_client_record(person, params[:client][:uuid], lab_location_id)
          create_client_identifier(identifiers, client.id)
        end
        client
      end
      # rubocop:enable Metrics/AbcSize

      def update_client(client, params, identifier_params)
        ActiveRecord::Base.transaction do
          update_person(client.person, params[:person])
          update_client_identifiers(client.id, identifier_params[:client_identifiers])
        end
      end

      def void_client(client, reason)
        client.void(reason)
        user = User.where(person_id: client.person.id).first
        client.person.void(reason) if user.nil?
        client_identifiers = ClientIdentifier.where(client_id: client.id)
        client_identifiers.each do |client_identifier|
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

      # rubocop:disable Metrics/MethodLength
      def serialize_client(client, person, client_identifiers)
        client_hash = {
          source: 'local',
          client_id: client.id,
          first_name: person.first_name,
          middle_name: person.middle_name.presence || '',
          last_name: person.last_name,
          sex: person.sex,
          date_of_birth: person.date_of_birth,
          birth_date_estimated: person.birth_date_estimated,
          uuid: client.uuid,
          created_at: client.created_date,
          lab_location: lab_location(client.lab_location_id)
        }
        client_identifiers.each do |identifier|
          client_hash[identifier.name] = identifier.value
        end
        client_hash
      end
      # rubocop:enable Metrics/MethodLength

      def serialize_clients(clients)
        clients.each_with_object([]) { |client, client_all| client_all << client(client.id) }
      end

      private

      def lab_location(lab_location_id)
        LabLocation.find_by(id: lab_location_id)
      end

      def find_or_initialize_client(uuid)
        uuid.present? ? Client.find_or_initialize_by(uuid:) : Client.new
      end

      def sanitize_middle_name(middle_name)
        middle_name.blank? || middle_name.downcase == 'unknown' ? '' : middle_name
      end

      def create_person(person_params, middle_name)
        Person.create!(
          first_name: person_params[:first_name],
          middle_name:,
          last_name: person_params[:last_name],
          sex: person_params[:sex],
          date_of_birth: person_params[:date_of_birth],
          birth_date_estimated: person_params[:birth_date_estimated],
          first_name_soundex: person_params[:first_name].soundex,
          last_name_soundex: person_params[:last_name].soundex
        )
      end

      def create_client_record(person, uuid, lab_location_id)
        Client.create!(person_id: person.id, uuid:, lab_location_id:)
      end

      # Client identifiers such as current_village, physical address
      def create_client_identifier(identifiers, client_id)
        return if identifiers.blank?

        identifiers.each do |identifier_type, identifier_value|
          create_identifier(identifier_type, identifier_value, client_id)
        end
      end

      def create_identifier(identifier_type, identifier_value, client_id)
        client_identifier_type = ClientIdentifierType.find_by_name(identifier_type)
        return if client_identifier_type.nil? || identifier_value.blank?

        update_or_create_client_identifier(
          client_id, client_identifier_type.id, identifier_value
        )
      end

      def update_or_create_client_identifier(client_id, client_identifier_type_id, value)
        client_identifier = ClientIdentifier.find_or_initialize_by(
          client_identifier_type_id:,
          client_id:
        )
        client_identifier.update!(value:)
      end

      def update_person(person, person_params)
        person.update!(person_params)
        update_soundex(person)
      end

      def update_soundex(person)
        person.update!(
          first_name_soundex: person.first_name.soundex,
          last_name_soundex: person.last_name.soundex
        )
      end

      def update_client_identifiers(client_id, identifiers)
        identifiers.each do |identifier|
          client_identifier_type = ClientIdentifierType.find_by_name(identifier[:type])
          next if client_identifier_type.nil?

          update_or_create_client_identifier(client_id, client_identifier_type.id, identifier[:value])
        end
      end

      def client_identifiers(client_id)
        ClientIdentifier
          .joins(:client_identifier_type)
          .where(client_id:)
          .select(
            'client_identifiers.id,
             client_identifier_types.name,
             client_identifiers.value'
          )
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
  # rubocop:enable Metrics/ModuleLength
end
