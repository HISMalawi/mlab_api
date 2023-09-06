# frozen_string_literal: true

# Stock management module
module StockManagement
  # module Stock fetcher service
  module StockFetcherService
    class << self
      def search_stock(item, page: 1, limit: 10)
        data = Stock.joins(:stock_item, :stock_location).where('stock_items.name LIKE ? OR stock_locations.name LIKE ?',
                                                               "%#{item}%", "%#{item}%").select("
          stock_items.id AS stock_item_id,
          stocks.id AS stock_id,
          stock_items.name,
          stock_items.description,
          stocks.quantity,
          stocks.minimum_order_level,
          stock_items.strength,
          stock_items.measurement_unit,
          stock_items.quantity_unit
        ")
        records = PaginationService.paginate(data, page:, limit:)
        meta = PaginationService.pagination_metadata(records)
        data = records.map do |stock|
          JSON.parse(stock.attributes.to_json)
        end
        { data:, meta: }
      end

      def stock_transaction_list(stocks, limit: 20)
        stock_list = []
        stocks[:data].each do |stock|
          stock_transactions = Stock.find_by_sql("
            SELECT
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
                LEFT JOIN
            stock_locations sl ON sl.id = s.stock_location_id
                INNER JOIN
            stock_items si ON s.stock_item_id = si.id AND s.id = #{stock['stock_id']}
                LEFT JOIN
            stock_categories sc ON sc.id = si.stock_category_id
                INNER JOIN
            stock_transactions st ON st.stock_id = s.id
                INNER JOIN
            stock_transaction_types stt ON stt.id = st.stock_transaction_type_id
            ORDER BY st.created_date DESC LIMIT #{limit}
          ")

          stock_transactions = stock_transactions.map do |stock_transaction|
            JSON.parse(stock_transaction.attributes.to_json)
          end
          stock[:stock_transactions] = stock_transactions
          stock_list << stock
        end
        {
          data: stock_list,
          meta: stocks[:meta]
        }
      end
    end
  end
end
