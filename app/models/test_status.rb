# frozen_string_literal: true

# Test status model
class TestStatus < VoidableRecord
  validates :status_reason_id, presence: false
  validates :status_id, presence: true
  belongs_to :test
  belongs_to :status

  def as_json(options = {})
    super(options.merge(methods: %i[status initiator], only: %i[id test_id status_id creator status_reason_id]))
  end

  def initiator
    User.find_by_id(creator).username
  end
end
