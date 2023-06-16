# frozen_string_literal: true

# Current Order status
class CreateCurrentOrderStatusView < ActiveRecord::Migration[7.0]
  def up
    execute "DROP VIEW IF EXISTS current_order_status;"
    execute <<-SQL 
    CREATE VIEW current_order_status AS
    SELECT os.order_id, os.status_id, s.name, os.created_date, os.updated_date, 
    CONCAT(p.first_name, ' ', p.last_name) AS creator,
    sr.description AS rejection_reason,
    os.person_talked_to
    FROM order_statuses os
    INNER JOIN (
    SELECT order_id, MAX(created_date) created_date
    FROM order_statuses
    GROUP BY order_id) cs ON cs.order_id = os.order_id AND cs.created_date = os.created_date
    INNER JOIN statuses s ON s.id = os.status_id
    INNER JOIN users u ON os.creator = u.id
    INNER JOIN people p ON p.id = u.person_id
    LEFT JOIN status_reasons sr ON sr.id = os.status_reason_id
    SQL
  end
  def down
    execute "DROP VIEW IF EXISTS current_order_status;"
  end
end
