# frozen_string_literal: true

# HomeDashboard Job
class HomeDashboardJob
  include Sidekiq::Job

  def perform
    to = Date.today
    from = to - 30
    HomeDashboardService.test_catalog
    HomeDashboardService.lab_configuration
    HomeDashboardService.clients
    Department.all.each do |department|
      HomeDashboardService.tests(from, to, department.name)
    end
  end
end
HomeDashboardJob.perform_async
