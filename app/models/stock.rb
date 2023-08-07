class Stock < VoidableRecord
  validates :name, uniqueness: true, presence: true
end
