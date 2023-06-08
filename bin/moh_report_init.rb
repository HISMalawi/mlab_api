include Reports::Moh::MigrationHelpers::ExecuteQueries

insert_into_report_raw_data_table()
insert_into_moh_data_report_table('haematology')
insert_into_moh_data_report_table('serology')
insert_into_moh_data_report_table('microbiology')
insert_into_moh_data_report_table('parasitology')
insert_into_moh_data_report_table('bloodbank')