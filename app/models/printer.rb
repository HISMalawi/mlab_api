class Printer < VoidableRecord
  validates :name, uniqueness: true, presence: true
end