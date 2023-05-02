module InstrumentsService
  class << self
    def find(page, page_size, search)
      if search.blank?
        data = Instrument.limit(page_size.to_i).offset((page.to_i - 1) * page_size.to_i)
      else
        filtered = Instrument.where("name LIKE ?", "%#{search}%").count
        data = Instrument.where("name LIKE ?", "%#{search}%").offset((page.to_i - 1) * page_size.to_i).limit(page_size.to_i)
      end

      data = data.order(id: :desc)

      total = Instrument.count

      { page: page.to_i,
        page_size: page_size.to_i,
        total: total.to_i,
        filtered: filtered || 0,
        data: data }
    end
  end
end
