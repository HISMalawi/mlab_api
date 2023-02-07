class Order < ApplicationRecord
  belongs_to :encounter
  belongs_to :priority
end
