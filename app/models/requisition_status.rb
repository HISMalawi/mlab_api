# frozen_string_literal: true

#  stock requisition status model
class RequisitionStatus < VoidableRecord
  belongs_to :stock_requisition
  belongs_to :stock_status

  def as_json(options = {})
    methods = %i[initiator stock_status]
    super(options.merge(methods:, only: %i[id stock_requisition_id created_date updated_date]))
  end

  def initiator
    user = User.find_by_id(creator)
    {
      id: user.id,
      username: user.username,
      first_name: user.person.first_name,
      last_name: user.person.last_name
    }
  end
end
