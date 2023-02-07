class Test < ApplicationRecord
  belongs_to :specimen
  belongs_to :order
  belongs_to :test_type
end
