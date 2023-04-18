Rails.logger = Logger.new(STDOUT)
module IblisService
  module LoadClientService
    class << self
      def get_iblis_clients(start_from, step)
        sql = "SELECT 
        p.id,
            p.name,
            COALESCE(p.dob, '0000-00-00') AS dob,
            p.dob_estimated,
            p.gender,
            p.email,
            p.address AS physical_address,
            p.phone_number AS phone,
            p.external_patient_number,
            u.username,
            p.deleted_at,
            p.created_at,
            p.updated_at
          FROM
            patients p
                INNER JOIN
            users u ON u.id = p.created_by WHERE p.id BETWEEN #{start_from} and #{start_from + step}"
        Iblis.find_by_sql(sql)
      end

      def load_client(clients)
        total = Iblis.find_by_sql("SELECT * FROM patients order by id DESC LIMIT 1")
        ActiveRecord::Base.transaction do
          clients.each do |client|
            name = client.name.split(' ')
            if name.length > 2
              first_name = name[0]
              middle_name = name[1]
              last_name = name[2]
            else
              first_name = name[0]
              middle_name = ''
              last_name = name[1]
            end
            User.current = User.find_by_username(client.username)
            client_details = {
              person: {
                first_name: first_name,
                middle_name: middle_name,
                last_name: last_name,
                date_of_birth: client.dob,
                birth_date_estimated: client.dob_estimated == 0 ? false : true,
                sex: client.gender == 0 ? 'M' : 'F',
                created_date: client.created_at,
                updated_date: client.updated_at
              },
              client_identifiers: [
                {
                  type: 'email',
                  value: client.email
                },
                {
                  type: 'physical_address',
                  value: client.physical_address
                },
                {
                  type: 'phone',
                  value: client.phone
                }
              ],
              client: {
                uuid: client.external_patient_number == '' ? '' : client.external_patient_number
              }
            }
            Rails.logger.info("Loading Client: #{client.name}")
            ClientManagement::ClientService.create_client(client_details)
          end
        end
      end

    end
  end
end