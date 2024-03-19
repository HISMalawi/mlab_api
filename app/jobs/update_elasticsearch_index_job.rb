# frozen_string_literal: true

# Update elastic search index job
class UpdateElasticsearchIndexJob
  include Sidekiq::Job

  def perform
    es = ElasticSearchService.new
    es.update_index
  end
end
UpdateElasticsearchIndexJob.perform_async
