ActiveRecord::Base.connection.execute(
  <<-SQL
    call get_test_data();
    
    call populate_moh_report_aggregate_data();
  SQL
)
