module OrderStatusesService
  class << self
    def update_order_status(params, status_name) 
      order_id = params[:order_id]
      status_reason_id = params[:status_reason_id] rescue nil
      person_talked_to = params[:person_talked_to] rescue nil
      status = Status.find_by(name: status_name)
      raise ActiveRecord::RecordNotFound, "Couldn't find status #{status_name}" if status.nil?

      response = nil
      ActiveRecord::Base.transaction do
        status_id = status.id
        new_order_status = OrderStatus.where(order_id:, status_id:).first
        if new_order_status.nil?
          new_order_status = OrderStatus.create!(order_id:, status_id:)
          Order.where(id: order_id).first&.update(status_id:)
        end
        new_order_status.update!(
          status_reason_id:,
          person_talked_to:
        )
        response = {
          id: order_id,
          status: Status.find(new_order_status.status_id)&.name
        }
      end
      response
    end
  end
end
