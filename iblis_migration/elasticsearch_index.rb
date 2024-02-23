# frozen_string_literal: true

# Index tests in elasticsearch
last_date = 90.days.ago.to_date
tests = Test.where("created_date > '#{last_date}'").order(id: :desc)
Parallel.map(tests, in_processes: 4) do |test|
  es = ElasticSearchService.new
  if es.ping
    es.index_test(test)
    puts "Last day to index tests: #{last_date}"
  else
    puts 'Lost connection to Elasticsearch'
    Parallel.break
  end
end
