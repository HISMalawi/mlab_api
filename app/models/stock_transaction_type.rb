# frozen_string_literal: true

# stock transaction type model
class StockTransactionType < VoidableRecord
  validates :name, uniqueness: true, presence: true

  before_save :strip_name_whitespace

  private

  def strip_name_whitespace
    self.name = name.strip if name.present?
  end
end
