# frozen_string_literal: true

puts 'Started Updating'
es = ElasticSearchService.new
es.update_index
puts 'Updating Completed'
