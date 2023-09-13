# frozen_string_literal: true

# module stock management
module StockManagement
  # module report
  module Report
    # module stock movement service
    module StockMovementService
      class << self
        def stock_movements(from, to, transaction_type)
          from = from.present? ? from.to_date.strftime('%Y-%m-%d') : Date.today.strftime('%Y-%m-%d')
          to = to.present? ? to.to_date.strftime('%Y-%m-%d') : Date.today.strftime('%Y-%m-%d')
          transaction_type_condition = transaction_type.present? ? " AND stt.name = '#{transaction_type}'" : ''
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
            st.reason,
            st.created_date AS transaction_date
            FROM
            stocks s
            INNER JOIN
            stock_transactions st ON st.stock_id = s.id AND st.voided = 0
                INNER JOIN
            stock_transaction_types stt ON stt.id = st.stock_transaction_type_id AND stt.voided = 0 #{transaction_type_condition}
                LEFT JOIN
            stock_locations sl ON sl.id = s.stock_location_id AND sl.voided = 0
                INNER JOIN
            stock_items si ON s.stock_item_id = si.voided = 0 AND si.voided = 0
                LEFT JOIN
            stock_categories sc ON sc.id = si.stock_category_id AND sc.voided = 0
            WHERE DATE(st.created_date) BETWEEN '#{from}' AND '#{to}'
            ORDER BY st.created_date DESC
          ")
          transactions = transactions.map do |transaction|
            JSON.parse(transaction.attributes.to_json)
          end
          {
            from:,
            to:,
            transaction_type:,
            data: transactions
          }
        end
      end
    end
  end
end
