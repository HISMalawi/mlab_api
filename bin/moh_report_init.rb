# frozen_string_literal: true

include Reports::Moh::MigrationHelpers::ExecuteQueries

Rails.logger = Logger.new($stdout)

def get_records(offset, limit)
  Test.where.not(id: ReportRawData.all.pluck('distinct test_id')).order(id: :desc).limit(limit).offset(offset).pluck('distinct id')
  # puts 'Loading report data for moh data'
  # insert_into_moh_data_report_table(department: 'Haematology')
  # insert_into_moh_data_report_table(department: 'Serology')
  # insert_into_moh_data_report_table(department: 'Microbiology')
  # insert_into_moh_data_report_table(department: 'Parasitology')
  # insert_into_moh_data_report_table(department: 'Blood Bank')
  # insert_into_moh_data_report_table(department: 'Biochemistry')
end

Rails.logger.info("Starting to process....")
total_records = Test.where.not(id: ReportRawData.all.pluck('distinct test_id')).order(id: :desc).count
batch_size = 5_000
offset = 0
count = total_records
loop do
  records = get_records(offset, batch_size)
  break if records.empty?

  Rails.logger.info("Processing batch #{offset} of #{total_records}: Remaining - #{count}  --Loading Report Data")
  test_ids = '(' + records.join(', ') + ')'
  ReportRawData.insert_data(test_id: test_ids)
  offset += batch_size
  count -= batch_size
end
