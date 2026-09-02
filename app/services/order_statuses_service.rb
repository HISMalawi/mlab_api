module OrderStatusesService
  class << self
    # Reject an order. Behaviour depends on which tests are targeted:
    #
    #   * a strict subset of the order's tests -> only those test statuses are
    #     set to "test-rejected"; the order status is left as-is (the specimen
    #     is still usable for the remaining tests).
    #   * all tests (or reject_all) -> every test is rejected AND the order
    #     status is set to "specimen-rejected".
    #
    # This prevents an order being marked specimen-rejected while some of its
    # tests are still processed/authorised.
    def reject_order(params)
      order_id = params[:order_id]
      raise ActiveRecord::RecordNotFound, "Couldn't find Order #{order_id}" unless Order.exists?(id: order_id)

      reason_id = resolve_status_reason(params)
      person_talked_to = params[:person_talked_to]

      all_test_ids = Test.where(order_id:, voided: 0).pluck(:id)
      requested_ids = (params[:test_ids].presence || []) & all_test_ids
      reject_entire_order = params[:reject_all].present? ||
                            requested_ids.blank? ||
                            requested_ids.to_set == all_test_ids.to_set

      target_test_ids = reject_entire_order ? all_test_ids : requested_ids

      ActiveRecord::Base.transaction do
        reject_tests(target_test_ids, reason_id, person_talked_to)
        reject_order_status(order_id, reason_id, person_talked_to) if reject_entire_order
      end

      {
        id: order_id,
        rejected_order: reject_entire_order,
        order_status: Status.find_by(id: Order.find(order_id).status_id)&.name,
        rejected_test_ids: target_test_ids
      }
    end

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

    private

    # Resolve the rejection reason id. A free-text `other_reason` (the "Other"
    # option) is turned into a StatusReason first, then used like a normal id.
    def resolve_status_reason(params)
      free_text = params[:other_reason]
      return params[:status_reason_id] if free_text.blank?

      StatusReason.for_description(free_text)&.id
    end

    def reject_tests(test_ids, reason_id, person_talked_to)
      return if test_ids.blank?

      status = Status.where(name: %w[test-rejected rejected]).first
      raise ActiveRecord::RecordNotFound, "Couldn't find status test-rejected" if status.nil?

      test_ids.each do |test_id|
        test_status = TestStatus.find_by(test_id:)
        next if test_status.nil?

        TestCatalog::TestStatusesService.update_test_status(test_status, status, reason_id, person_talked_to)
      end
    end

    def reject_order_status(order_id, reason_id, person_talked_to)
      status = Status.find_by(name: 'specimen-rejected')
      raise ActiveRecord::RecordNotFound, "Couldn't find status specimen-rejected" if status.nil?

      order_status = OrderStatus.where(order_id:, status_id: status.id).first
      if order_status.nil?
        order_status = OrderStatus.create!(order_id:, status_id: status.id)
        Order.where(id: order_id).first&.update(status_id: status.id)
      end
      order_status.update!(status_reason_id: reason_id, person_talked_to:)
    end
  end
end
