# frozen_string_literal: true

require 'elasticsearch'

# ElasticSearchService module
class ElasticSearchService
  def initialize
    @elasticsearch = Elasticsearch::Client.new
  end

  def ping
    @elasticsearch.ping
  end

  def index_test(test)
      @elasticsearch.index(
        index: 'tests',
        id: test.id,
        body: {
          test_id: test.id,
          patient_name: test&.order&.encounter&.client&.person&.fullname,
          accession_number: test&.order&.accession_number,
          tracking_number: test&.order&.tracking_number,
          test_name: test&.test_type&.name,
          location: test&.order&.encounter&.facility_section&.name,
          test_status: Status.where(id: test&.status_id).first&.name,
          order_status: Status.where(id: test&.order&.status_id).first&.name,
          test_time_created: test&.created_date
        }
      )
      puts "Indexing record---> tracking_number: #{test&.order&.tracking_number}  Accession number: #{test&.accession_number} current date: #{test.created_date.to_date}"
  rescue StandardError => e
      puts e.message
  end

  def update_index
    params = { index: 'tests', size: 1, sort: 'test_id:desc' }
    begin
      es_test_id = @elasticsearch.search(params)['hits']['hits'][0]['sort'][0]
      tests = Test.where(id: (es_test_id + 1)...)
      Parallel.map(tests, in_processes: 4) do |test|
        @elasticsearch.create(
          index: 'tests',
          id: test&.id,
          body: {
            test_id: test&.id,
            patient_name: test&.order&.encounter&.client&.person&.fullname,
            accession_number: test&.order&.accession_number,
            tracking_number: test&.order&.tracking_number,
            test_name: test&.test_type&.name,
            location: test&.order&.encounter&.facility_section&.name,
            test_status: Status.where(id: test&.status_id).first&.name,
            order_status: Status.where(id: test&.order&.status_id).first&.name,
            test_time_created: test&.created_date
          }
        )
        puts "Updating record---> tracking_number: #{test&.order&.tracking_number}"
      end
    rescue StandardError => e
      puts e.message
    end
  end

  def search(q, facility_sections)
    base_query = {
      bool: {
        should: [
          {
            match: {
              patient_name: {
                query: q,
                fuzziness: 2
              }
            }
          },
          {
            match: {
              location: {
                query: q
              }
            }
          },
          {
            match: {
              test_name: {
                query: q,
                fuzziness: 2
              }
            }
          },
          {
            match: {
              accession_number: {
                query: "#{GlobalService.current_location&.code}#{q}"
              }
            }
          },
          {
            match: {
              accession_number: {
                query: q
              }
            }
          },
          {
            match: {
              tracking_number: {
                query: q
              }
            }
          }
        ]
      }
    }
    if facility_sections.present?
      base_query[:bool][:filter] = {
        terms: { 'location.keyword' => facility_sections }
      }
    end
    # debugger
    params = {
      index: 'tests',
      from: 0,
      size: 10_000,
      body: {
        min_score: q.present? ? 0.05345 : 0.0,
        query: q.present? ? base_query : { bool: { filter: { terms: { 'location.keyword' => facility_sections } } } }
      }
    }
    test_ids = []
    response = @elasticsearch.search(params)['hits']['hits']
    response.each do |hit|
      test_ids << hit['_source']['test_id']
    end
    test_ids = Test.where(order_id: Order.where(accession_number: q).first&.id).pluck('id') if test_ids.empty?
    test_ids
  end
end
