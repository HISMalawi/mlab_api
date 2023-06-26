include Reports::Moh::MigrationHelpers::ExecuteQueries

def run_report_script
  min_test_id = ReportRawData.minimum(:test_id)
  m_test_id = Test.minimum(:id)
  test_ids = []
  if min_test_id.nil?
    test_ids = Test.all.pluck('id').reverse
  elsif !m_test_id.nil? && !(min_test_id == m_test_id)
    test_ids = Test.where("id <= #{min_test_id}").pluck('id').reverse
  end
  Parallel.each(test_ids, in_processes: 4) do |test_id|
    puts "Loading into report data for #{test_id} \n"
    insert_into_report_raw_data_table(test_id)
  end
  puts 'Loading report data for moh data'
  insert_into_moh_data_report_table(department: 'Haematology')
  insert_into_moh_data_report_table(department: 'Serology')
  insert_into_moh_data_report_table(department: 'Microbiology')
  insert_into_moh_data_report_table(department: 'Parasitology')
  insert_into_moh_data_report_table(department: 'Blood Bank')
  insert_into_moh_data_report_table(department: 'Biochemistry')
end

loop do
  begin
    run_report_script
    break
  rescue => e
    puts "Error occurred: #{e.message}"
    puts "Restarting the process from where the process stop"
    run_report_script
  end
end
