# frozen_string_literal: true

Rails.logger = Logger.new($stdout)

def iblis_cs_observations(offset, limit, creator)
  Iblis.find_by_sql("
    SELECT
      id,
      user_id AS creator,
      test_id,
      observation AS description,
      created_at AS created_date,
      updated_at AS updated_date,
      created_at AS observation_datetime,
      user_id AS updated_by,
      0 AS voided,
      NULL AS voided_by,
      NULL AS voided_reason,
      NULL AS voided_date
      FROM
      culture_worksheet
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_cs_observations_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
      culture_worksheet
  ")[0]
end
ActiveRecord::Base.connection.execute("SET sql_mode='NO_ZERO_DATE'")
creator = User.first.id
Rails.logger.info('Starting to process....')
total_records = iblis_cs_observations_count.count
batch_size = 50_000
offset = 0
count = total_records
loop do
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
  records = iblis_cs_observations(offset, batch_size, creator)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Culture Observations-- step(9 of 10)")
  CultureObservation.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")
end
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")
ActiveRecord::Base.connection.execute("SET sql_mode=''")