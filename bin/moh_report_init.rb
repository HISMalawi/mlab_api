include Reports::Moh::MigrationHelpers::ExecuteQueries

test_ids = Test.all.pluck('id')
test_ids.reverse.each do |test_id|
  puts "Loading into report data for #{test_id}"
  insert_into_report_raw_data_table(test_id)
end
insert_into_moh_data_report_table(department: 'Haematology')
insert_into_moh_data_report_table(department: 'Serology')
insert_into_moh_data_report_table(department: 'Microbiology')
insert_into_moh_data_report_table(department: 'Parasitology')
insert_into_moh_data_report_table(department: 'Blood Bank')
insert_into_moh_data_report_table(department: 'Biochemistry')