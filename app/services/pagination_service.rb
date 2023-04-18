module PaginationService
  class << self
    def pagination_metadata(collection)
      {
        current_page: collection.current_page,
        next_page: collection.next_page,
        prev_page: collection.prev_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count
      }
    end

    def paginate(collection, page: 1, limit: 10)
      collection.page(page).per(limit)
    end
  end
end