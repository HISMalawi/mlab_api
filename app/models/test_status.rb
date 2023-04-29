class TestStatus < VoidableRecord
  validates :status_reason_id, presence: false
  validates :creator, presence: true
  validates :status_id, presence: true
  
  belongs_to :test
  belongs_to :status
end
