# frozen_string_literal: true

# load remaining cs obs
module CultureObservations
  class << self
    def iblis_cs_observations(test_id, _creator)
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
        WHERE test_id > #{test_id}
      ")
    end

    def process_cs_observations(test_id)
      ActiveRecord::Base.connection.execute("SET sql_mode='NO_ZERO_DATE'")
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
      creator = User.first.id
      records = iblis_cs_observations(test_id, creator)
      Rails.logger.info("Processing culture observations #{records.count}: Remaining - 0 --Culture Observations-- step(6 of 8)")
      CultureObservation.upsert_all(records.map(&:attributes), returning: false) unless records.empty?
      ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
      ActiveRecord::Base.connection.execute("SET sql_mode=''")
    end
  end
end
