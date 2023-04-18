class Order < VoidableRecord
  belongs_to :encounter
  belongs_to :priority
end
