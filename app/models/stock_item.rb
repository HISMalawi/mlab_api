# frozen_string_literal: true

# stock item model
class StockItem < VoidableRecord
  belongs_to :stock_category
  belongs_to :measurement_unit, class_name: 'StockUnit', foreign_key: 'measurement_unit'
  validates :name, uniqueness: true, presence: true

  before_save :strip_name_whitespace

  private

  def strip_name_whitespace
    self.name = name.strip if name.present?
  end
end
