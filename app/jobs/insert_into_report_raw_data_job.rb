class InsertIntoReportRawDataJob
  include Sidekiq::Job

  def perform(test_id)
    ReportRawData.insert_data(test_id: test_id)
  end
end
