class StatusReason < RetirableRecord
  validates :description, uniqueness: true, presence: true
end
