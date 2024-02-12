# frozen_string_literal: true

require_relative '../iblis/iblis_service/drug_organism_service.rb'
require_relative '../iblis/iblis_service/load_client_service.rb'
require_relative '../iblis/iblis_service/measure_service.rb'
require_relative '../iblis/iblis_service/status_service.rb'

Rails.logger = Logger.new($stdout)

def iblis_drug_susceptibility(offset, limit, creator)
  Iblis.find_by_sql("
    SELECT
      id,
      user_id AS creator,
      test_id,
      organism_id,
      drug_id,
      zone,
      interpretation,
      created_at AS created_date,
      updated_at AS updated_date,
      user_id AS updated_by,
      CASE WHEN deleted_at IS NOT NULL THEN 1 ELSE 0 END AS voided,
      CASE WHEN deleted_at IS NOT NULL THEN user_id ELSE NULL END AS voided_by,
      NULL AS voided_reason,
      CASE WHEN deleted_at IS NOT NULL THEN deleted_at ELSE NULL END AS voided_date
      FROM
      drug_susceptibility
    LIMIT #{limit} OFFSET #{offset}
  ")
end

def iblis_drug_susceptibility_count
  Iblis.find_by_sql("
    SELECT
      count(*) AS count
    FROM
    drug_susceptibility
  ")[0]
end
ActiveRecord::Base.connection.execute("SET sql_mode='NO_ZERO_DATE'")
creator = User.first.id
Rails.logger.info('Starting to process....')
total_records = iblis_drug_susceptibility_count.count
batch_size = 50_000
offset = 0
count = total_records
loop do
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
  records = iblis_drug_susceptibility(offset, batch_size, creator)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count} --Drug Susceptiblity-- step(9 of 10)")
  DrugSusceptibility.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
  offset += batch_size
  count -= batch_size
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")
end
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")
ActiveRecord::Base.connection.execute("SET sql_mode=''")