include Reports::Moh::MigrationHelpers::ExecuteQueries

test_ids = Test.all.pluck('id').reverse
Parallel.each(test_ids, in_processes: 4) do |test_id|
  puts "Loading into report data for #{test_id} \n"
  insert_into_report_raw_data_table(test_id)
end
insert_into_moh_data_report_table(department: 'Haematology')
insert_into_moh_data_report_table(department: 'Serology')
insert_into_moh_data_report_table(department: 'Microbiology')
insert_into_moh_data_report_table(department: 'Parasitology')
insert_into_moh_data_report_table(department: 'Blood Bank')
insert_into_moh_data_report_table(department: 'Biochemistry')