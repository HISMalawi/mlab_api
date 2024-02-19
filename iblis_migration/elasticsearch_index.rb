# frozen_string_literal: true

# Index tests in elasticsearch
tests = Test.where("created_date > '#{90.days.ago.to_date}'").order(id: :desc)
total = tests.count
remaining = 0
tests.each do |test|
  es = ElasticSearchService.new
  if es.ping
    es.index_test(test)
    remaining += 1
    puts "Remaining tests to index: #{total - remaining}, indexing last 90 days data"
  else
    puts 'Lost connection to elasticsearch'
    break
  end
end
