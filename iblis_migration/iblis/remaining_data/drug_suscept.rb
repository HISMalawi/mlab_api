# frozen_string_literal: true

# load drug susceptibility remaining iblis data
module DrugSuscept
  class << self
    def iblis_drug_susceptibility(test_id, _creator)
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
          drug_susceptibility where test_id > #{test_id}
      ")
    end

    def process_drug_susceptibilities(test_id)
      Rails.logger = Logger.new(STDOUT)
      ActiveRecord::Base.connection.execute("SET sql_mode='NO_ZERO_DATE'")
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
      creator = User.first.id
      records = iblis_drug_susceptibility(test_id, creator)
      Rails.logger.info("Processing Drug Susceptiblity #{records.count}: Remaining - 0 --Drug Susceptiblity-- step(7 of 8)")
      DrugSusceptibility.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
      ActiveRecord::Base.connection.execute("SET sql_mode=''")
    end
  end
end
