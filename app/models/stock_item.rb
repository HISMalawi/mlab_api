# frozen_string_literal: true

# stock item model
class StockItem < VoidableRecord
  belongs_to :stock_category
  validates :name, uniqueness: true, presence: true

  before_save :strip_name_whitespace
  before_save :set_measurement_unit

  private

  def set_measurement_unit
    self.measurement_unit = StockUnit.find(measurement_unit).id
  end

  def strip_name_whitespace
    self.name = name.strip if name.present?
  end
end
