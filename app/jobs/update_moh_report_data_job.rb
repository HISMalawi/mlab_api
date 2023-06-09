class UpdateMohReportDataJob
  include Reports::Moh::MigrationHelpers::ExecuteQueries
  include Sidekiq::Job

  def perform(created_date)
    insert_into_moh_data_report_table(department: 'Haematology', action: 'update', time_filter: created_date.to_s)
    insert_into_moh_data_report_table(department: 'Serology', action: 'update', time_filter: created_date.to_s)
    insert_into_moh_data_report_table(department: 'Microbiology', action: 'update', time_filter: created_date.to_s)
    insert_into_moh_data_report_table(department: 'Parasitology', action: 'update', time_filter: created_date.to_s)
    insert_into_moh_data_report_table(department: 'Blood Bank', action: 'update', time_filter: created_date.to_s)
    insert_into_moh_data_report_table(department: 'Biochemistry', action: 'update', time_filter: created_date.to_s)
  end
end
