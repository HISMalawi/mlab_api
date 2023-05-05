class TestStatus < VoidableRecord
  validates :status_reason_id, presence: false
  validates :status_id, presence: true
  
  belongs_to :test
  belongs_to :status

  def as_json(options = {})
    super(options.merge(methods: :status, only: %i[id test_id status_id status_reason_id]))
  end
end
