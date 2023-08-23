# frozen_string_literal: true

# stock status model
class StockStatus < VoidableRecord
  validates :name, uniqueness: true, presence: true

  def as_json(options = {})
    super(options.merge(only: %i[id name]))
  end
end
