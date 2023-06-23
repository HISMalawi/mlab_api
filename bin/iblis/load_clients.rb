#  last_patient_id = Iblis.find_by_sql("SELECT * FROM patients order by id DESC LIMIT 1")[0].id
# last_patient_id = 1000
# def run(start_from, step, last_patient_id)
#   clients = IblisService::LoadClientService.get_iblis_clients(start_from, step)
#   IblisService::LoadClientService.load_client(clients)
#   start_from = start_from + step + 1
#   if start_from < last_patient_id
#     run(start_from, step, last_patient_id)
#   end
# end

# run(1, 10, last_patient_id)
Rails.logger = Logger.new(STDOUT)
def load_people(offset, limit)
  Iblis.find_by_sql("
    SELECT
      p.id AS id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(p.name, ' ', 1), ' ', -1) AS first_name,
        '' AS middle_name,
        SUBSTRING_INDEX(p.name, ' ', -1) AS last_name,
        CASE 
            WHEN p.gender = 0 THEN 'M'
            WHEN p.gender = 1 THEN 'F'
        END AS sex,
        COALESCE(p.dob, '0000-00-00') AS date_of_birth,
        p.dob_estimated AS birth_date_estimated,
      IF(p.deleted_at IS NOT NULL, 1, 0) AS voided,
        NULL AS voided_by,
        NULL AS voided_reason,
        NULL AS voided_reason,
      IF(p.created_by = 0, 1, p.created_by) AS creator,
        p.created_at AS created_date,
        p.updated_at AS updated_date,
      IF(p.created_by = 0, 1, p.created_by)  AS updated_by
    FROM patients p LIMIT #{limit} OFFSET #{offset}
  ")
end
def load_clients(offset, limit)
  Iblis.find_by_sql("
    SELECT
      p.id AS id,
      p.id AS person_id,
      NULL AS uuid,
      IF(p.deleted_at IS NOT NULL, 1, 0) AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_reason,
      IF(p.created_by = 0, 1, p.created_by) AS creator,
      p.created_at AS created_date,
      p.updated_at AS updated_date,
      IF(p.created_by = 0, 1, p.created_by) AS updated_by
    FROM patients p LIMIT #{limit} OFFSET #{offset}
  ")
end

def get_count
  Iblis.find_by_sql("
    SELECT
     count(*) AS count
    FROM patients p
  ")[0]
end

def update_user_details
  ActiveRecord::Base.transaction do
    # Load Users
    users = Iblis.find_by_sql("SELECT * FROM users")
    users.each do |user|
      sex = user.gender == 0 ? 'M' : 'F'
      name = user.name.split()
      middle_name = ''
      if name.length > 1
        first_name = name[0]
        last_name = name.length> 2 ? name[2] : name[1]
        middle_name = name[1] if name.length > 2
      else
        first_name = name[0]
        last_name = name[0]
      end
      person = Person.where(first_name: first_name, last_name: last_name, sex: sex, created_date: user.created_at, updated_date: user.updated_at).first
      if person.nil?
        Rails.logger.info("=========Loading Person: #{user.name}===========")
        person = Person.create!(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, created_date: user.created_at, updated_date: user.updated_at)
      end
      if UserManagement::UserService.username_exists? user.username
        mlab_user = User.find_by_username(user.username)
        mlab_user.update(person_id: person.id)
      else
        Rails.logger.info("=========Loading User: #{user.username}===========")
        mlab_user = User.new(id: user.id, person_id: person.id, username: user.username, password: user.password, is_active:0)
        if mlab_user.save!
          if !user.deleted_at.nil?
            Rails.logger.info("=========Voiding  deleted User: #{user.username}===========")
            mlab_user.update!(is_active: 1)
          end
        end 
      end
    end
  end
end

Rails.logger.info("Starting to process people....")
total_records = get_count.count
batch_size = 10000
offset = 0
count = total_records
loop do
  records = load_people(offset, batch_size)
  c_records = load_clients(offset, batch_size)
  break if records.empty?
  Rails.logger.info("Processing batch  #{offset} of #{total_records}: Remaining - #{count} --CLIENTS-- step(1 of 10)")
  Person.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  Client.upsert_all(c_records.map(&:attributes), returning: false) unless c_records.empty?
  offset += batch_size
  count -= batch_size
end
update_user_details


