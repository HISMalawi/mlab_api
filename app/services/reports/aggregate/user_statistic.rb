module Reports
  module Aggregate
    class UserStatistic
      def generate_report
        users = User.all
        users_test_counts = users.map do |user|
          tests_completed = TestStatus.where(creator: user.id, status_id: Status.find_by_name('completed').id).count
          tests_received = Test.joins(order: :order_statuses).where(order_statuses: { creator: user.id }).where('order_statuses.status_id = ?', Status.find_by_name('specimen-accepted').id).count
          specimen_collected = OrderStatus.where(creator: user.id, status_id: Status.find_by_name('pending').id).count
          specimen_rejected = OrderStatus.where(creator: user.id, status_id: Status.find_by_name('specimen-rejected').id).count
          tests_performed = TestStatus.where(creator: user.id, status_id: Status.find_by_name('verified').id).count
          tests_authorized = TestStatus.where(creator: user.id, status_id: Status.find_by_name('verified').id).count
          {
            user: user.username,
            tests_completed: tests_completed,
            tests_received: tests_received,
            specimen_collected: specimen_collected,
            specimen_rejected: specimen_rejected,
            tests_performed: tests_performed,
            tests_authorized: tests_authorized
          }
        end
      end
    end
  end
end
