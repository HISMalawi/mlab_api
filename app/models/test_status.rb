class TestStatus < ApplicationRecord
  belongs_to :test
  belongs_to :status
  belongs_to :status_reason
end
