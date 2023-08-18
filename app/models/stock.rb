# frozen_string_literal: true

# stock model
class Stock < VoidableRecord
  validates :name, uniqueness: true, presence: true
  belongs_to :stock_category
  belongs_to :stock_location

  before_save :strip_name_whitespace

  private

  def strip_name_whitespace
    self.name = name.strip! if name.present?
  end
end
