module OrderStatusesService
  class << self
    def update_order_status(params, status_name) 
      order_id = params[:order_id]
      status_reason_id = params[:status_reason_id] rescue nil
      person_talked_to = params[:person_talked_to] rescue nil

      status = Status.find_by(name: status_name)
      order_status = OrderStatus.find_or_create_by!({
        order_id: order_id,
        status_id: status[:id],
        status_reason_id: status_reason_id,
        person_talked_to: person_talked_to
      })
      
      # if ["specimen-rejected", "specimen-accepted"].include?(status_name.downcase) 
        # tests = Test.where(:order_id => order_id).pluck(:id)
        # if tests.present?
        #   tests.each do |tid| 
        #     TestStatus.find_or_create_by!({
        #       test_id: tid,
        #       status_id: status[:id],
        #       status_reason_id: status_reason_id
        #     })
        #   end
        # end
      # end

      order_status
    end
  end
end