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

    def create_instrument(instrument_params, test_types)
      ActiveRecord::Base.transaction do
        @instrument = Instrument.create!(instrument_params)
        test_types.each do |test_type_id|
          unless test_type_id.is_a?(Integer)
            raise ArgumentError, "Test type id must be an integer"
          end
          InstrumentTestTypeMapping.create!(
            instrument_id: @instrument.id,
            test_type_id:
          )
        end
      end
      @instrument
    end

    def update_instrument(instrument, instrument_params, test_types)
      ActiveRecord::Base.transaction do
        instrument.update!(instrument_params)
        test_types.each do |test_type_id|
          unless test_type_id.is_a?(Integer)
            raise ArgumentError, "Test type id must be an integer"
          end
          InstrumentTestTypeMapping.find_or_create_by!(
            instrument_id: instrument.id,
            test_type_id:
          )
        end
        InstrumentTestTypeMapping.where(instrument_id: instrument.id).where.not(test_type_id: test_types).each do |instrument_test_type_mapping|
          instrument_test_type_mapping.void('Removed from instrument_test_type_mapping')
        end
      end
    end

  end
end
