# frozen_string_literal: true

# create a new view
class CreateCurrentTestStatusView < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
    CREATE VIEW current_test_status AS
    SELECT ts.test_id, ts.status_id, s.name, ts.created_date, ts.updated_date, 
    CONCAT(p.first_name, ' ', p.last_name) AS creator,
    sr.description AS rejection_reason,
    ts.person_talked_to
    FROM test_statuses ts
    INNER JOIN (
    SELECT test_id, MAX(created_date) created_date
    FROM test_statuses
    GROUP BY test_id) cs ON cs.test_id = ts.test_id AND cs.created_date = ts.created_date
    INNER JOIN statuses s ON s.id = ts.status_id
    INNER JOIN users u ON ts.creator = u.id
    INNER JOIN people p ON p.id = u.person_id
    LEFT JOIN status_reasons sr ON sr.id = ts.status_reason_id
   SQL
  end

  def down
    execute "DROP VIEW IF EXISTS current_test_status"
  end
end
