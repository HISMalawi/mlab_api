class Stock < VoidableRecord
  validates :name, uniqueness: true, presence: true
  belongs_to :stock_category
  belongs_to :stock_location
  def self.create_from_params(params)
    stock = new
    stock.assign_attributes(sanitize_for_mass_assignment(params))
    stock.save
    stock
  end
end
