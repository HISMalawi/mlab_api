# frozen_string_literal: true

# Current Order status
class CreateCurrentOrderStatusView < ActiveRecord::Migration[7.0]
  def change
    execute 'CREATE VIEW current_order_status AS
    SELECT os.order_id, os.status_id, s.name
    FROM order_statuses os
    INNER JOIN (
    SELECT order_id, MAX(created_date) created_date
    FROM order_statuses
    GROUP BY order_id) cs ON cs.order_id = os.order_id AND cs.created_date = os.created_date
    INNER JOIN statuses s ON s.id = os.status_id
    '
  end
end
