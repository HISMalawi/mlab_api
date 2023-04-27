class Test < VoidableRecord
  belongs_to :specimen
  belongs_to :order
  belongs_to :test_type
  has_many :test_status
end
