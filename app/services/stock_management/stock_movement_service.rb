# frozen_string_literal: true

# Stock management module
module StockManagement
  # stock movement service
  module StockMovementService
    class << self
      def stock_movement_statuses
        StockMovement.find_by_sql("
          SELECT
            sm.id, sm.id AS stock_movement_id, ss.id AS stock_status_id, ss.name AS stock_status,
            sm.movement_to,
            smt.created_date AS status_date, sm.created_date AS movement_date
          FROM
            stock_movements sm
                INNER JOIN
            stock_movement_statues smt ON sm.id = smt.stock_movement_id AND smt.voided = 0
            INNER JOIN stock_statuses ss ON ss.id = smt.stock_status_id AND ss.voided = 0
          WHERE
              sm.voided = 0 AND
              smt.created_date = (
                SELECT
                  MAX(created_date)
                FROM
                    stock_movement_statues smti
                WHERE
                  smti.stock_movement_id = smt.stock_movement_id
              )
          GROUP BY sm.id, ss.id, smt.created_date
          ORDER BY smt.created_date DESC LIMIT 100
        ")
      end

      def stock_movements(stock_movement_statuses)
        stock_moved = []
        stock_movement_statuses.each do |stock_movement_status|
          transaction_ids = StockMovementStatus.where(
            stock_movement_id: stock_movement_status.stock_movement_id,
            stock_status_id: stock_movement_status.stock_status_id
          ).pluck(:stock_transactions_id).join(',')
          transactions = Stock.find_by_sql("
            SELECT
            st.id as id,
            s.id AS stock_id,
            s.stock_item_id,
            si.name,
            si.description,
            s.quantity AS consolidated_available_balance,
            s.minimum_order_level,
            sl.name AS stock_location,
            sc.name AS stock_category,
            si.measurement_unit,
            si.quantity_unit,
            si.strength,
            st.lot,
            stt.name AS transaction_type,
            st.batch,
            st.quantity AS transacted_quantity,
            st.expiry_date,
            st.receiving_from,
            st.sending_to,
            st.remaining_balance AS after_transaction_remaining_balance,
            st.remarks,
            st.created_date AS transaction_date
            FROM
            stocks s
            INNER JOIN
            stock_transactions st ON st.stock_id = s.id AND st.id IN (#{transaction_ids}) AND st.voided = 0
                INNER JOIN
            stock_transaction_types stt ON stt.id = st.stock_transaction_type_id AND stt.voided = 0
                LEFT JOIN
            stock_locations sl ON sl.id = s.stock_location_id AND sl.voided = 0
                INNER JOIN
            stock_items si ON s.stock_item_id = si.id AND si.voided = 0
                LEFT JOIN
            stock_categories sc ON sc.id = si.stock_category_id AND sc.voided = 0
            ORDER BY st.created_date DESC
          ")
          transactions = transactions.map do |transaction|
            JSON.parse(transaction.attributes.to_json)
          end
          stock_movement_status = JSON.parse(stock_movement_status.attributes.to_json)
          stock_movement_status['stock_transactions'] = transactions
          stock_moved << stock_movement_status
        end
        stock_moved
      end

      # Continue working on this method
      def stock_adjustment(stock_id, lot, batch, expiry_date, quantity_to_adjusted, reason, notes)
        stock_transaction = StockManagement::StockService.last_stock_transaction(
          stock_id, lot, batch, expiry_date
        )
        raise ActiveRecord::RecordNotFound, 'Stock transaction not found' if stock_transaction.blank?

        ActiveRecord::Base.transaction do
          reason = StockAdjustmentReason.find_or_create_by!(name: reason) if reason.present?
          StockManagement::StockService.reverse_stock_transaction(
            stock_transaction.id, reason.name, 'Adjust Stock', quantity_to_adjusted, notes
          )
          stock_item_id = Stock.find(stock_id).stock_item_id
          StockManagement::StockService.positive_stock_adjustment(stock_item_id, quantity_to_adjusted)
        end
      end
    end
  end
end
