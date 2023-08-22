# frozen_string_literal: true

#  stock requisition status model
class RequisitionStatus < VoidableRecord
  belongs_to :stock_requisition
  belongs_to :stock_status
end
