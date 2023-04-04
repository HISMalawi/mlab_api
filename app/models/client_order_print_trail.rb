# frozen_string_literal: true

class ClientOrderPrintTrail < VoidableRecord
  belongs_to :order
end
