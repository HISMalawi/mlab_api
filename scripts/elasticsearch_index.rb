# frozen_string_literal: true

# Index tests in elasticsearch
Test.all.order(id: :desc).each do |test|
  es = ElasticSearchService.new
  es.index_test(test)
end
