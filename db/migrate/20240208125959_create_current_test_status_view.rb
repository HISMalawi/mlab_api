# frozen_string_literal: true

# create a new view
class CreateCurrentTestStatusView < ActiveRecord::Migration[7.0]
  def change
    execute 'CREATE VIEW current_test_status AS
    SELECT ts.test_id, ts.status_id, s.name
    FROM test_statuses ts
    INNER JOIN (
    SELECT test_id, MAX(created_date) created_date
    FROM test_statuses
    GROUP BY test_id) cs ON cs.test_id = ts.test_id AND cs.created_date = ts.created_date
    INNER JOIN statuses s ON s.id = ts.status_id
    '
  end
end
