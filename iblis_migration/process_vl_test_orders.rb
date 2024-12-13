# frozen_string_literal: true

require 'csv'

def process_nlims_order(accession_numbers)
  accession_numbers.each do |accession_number|
    nlims
    User.current = User.first
    nlims_order = search_order_from_nlims_by_tracking_number(accession_number)
    puts nlims_order
    create_order_from_nlims(nlims_order)
  end
end

def start_folder_monitoring(folder_path)
  listener = Listen.to(folder_path) do |modified, added, _removed|
    puts "Detected changes in folder: #{folder_path}"
    filename = modified.first || added.first
    accession_numbers = CSV.read(filename).map { |row| row[0] }
    puts 'Delaying for 6 minutes before processing orders'
    sleep 360
    process_nlims_order(accession_numbers)
  end
  listener.start
  puts "Listening for changes in #{folder_path}..."
  sleep
end

def nlims
  config_data = YAML.load_file("#{Rails.root}/config/application.yml")
  nlims_config = config_data['nlims_service']
  raise NlimsError, 'nlims_service configuration not found' if nlims_config.nil?

  @nlims_service = Nlims::RemoteService.new(
    base_url: "#{nlims_config['base_url']}:#{nlims_config['port']}",
    token: '',
    username: nlims_config['vl_username'],
    password: nlims_config['vl_password']
  )
  raise Errno::ECONNREFUSED, 'Nlims service is not available' unless @nlims_service.ping_nlims

    auth = @nlims_service.authenticate
    raise NlimsError, 'Unable to authenticate to nlims service' unless auth
end

def search_order_from_nlims_by_tracking_number(tracking_number)
  response = @nlims_service.query_order_by_tracking_number(tracking_number)
  raise NlimsNotFoundError, 'Order not available in NLIMS' if response.nil?

  response
end

def create_order_from_nlims(nlims_order)
  nlims_order[:results] = [] if nlims_order[:results].nil?
  ActiveRecord::Base.transaction do
    order = @nlims_service.merge_or_create_order(nlims_order)
    puts "Order created successfully with id #{order.id}"
    tests = Test.where(order_id: order.id)
    tests.each do |lab_test|
      update_status_trail(lab_test, status('Pending'))
      update_status_trail(lab_test, status('Started'))
      update_test_result(lab_test)
      update_status_trail(lab_test, status('Verified'))
      puts "Test #{lab_test.id} updated successfully"
    end
    puts 'All tests updated successfully'
  end
end

def status(name)
  Status.find_by(name:).id
end

def update_status_trail(lab_test, status_id)
  TestStatus.create(test_id: lab_test.id, status_id:)
  lab_test.update(status_id:)
end

def update_test_result(lab_test)
  test_indicators = TestTypeTestIndicator.where(test_types_id: lab_test.test_type_id)
  test_indicators.each do |test_indicator|
    TestResult.create(
      test_id: lab_test.id,
      test_indicator_id: test_indicator.test_indicators_id,
      value: rand(4..10_000),
      result_date: Time.now
    )
  end
  update_status_trail(lab_test, status('Completed'))
end

start_folder_monitoring("#{Rails.root}/public")
