module PaginationService
  class << self
    def pagination_metadata(paginated_collection)
      {
        current_page: paginated_collection.current_page,
        next_page: paginated_collection.next_page,
        prev_page: paginated_collection.prev_page,
        total_pages: paginated_collection.total_pages,
        total_count: paginated_collection.total_count
      }
    end

    def paginate(collection, page: 1, limit: 10)
      collection.page(page).per(limit)
    end

    def paginate_array(collection, page: 1, limit: 10)
      Kaminari.paginate_array(collection).page(page).per(limit)
    end
  end
end
