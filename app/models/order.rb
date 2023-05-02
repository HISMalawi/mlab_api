class Order < VoidableRecord
  belongs_to :encounter
  belongs_to :priority
  has_many :tests
end
