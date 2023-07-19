class InsertIntoReportRawDataJob
  include Sidekiq::Job

  def perform(test_id)
    id = test_id.to_s
    test_id = "(#{id})"
    ReportRawData.insert_data(test_id:)
  end
end
