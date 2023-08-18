# frozen_string_literal: true

# stock category model
class StockCategory < VoidableRecord
  validates :name, uniqueness: true, presence: true

  before_save :strip_name_whitespace

  private

  def strip_name_whitespace
    self.name = name.strip if name.present?
  end
end
