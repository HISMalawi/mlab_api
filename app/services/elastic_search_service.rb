# frozen_string_literal: true

require 'elasticsearch'
require 'bantu_soundex'

# ElasticSearchService module
class ElasticSearchService
  def initialize
    @elasticsearch = Elasticsearch::Client.new
    @index_name = 'tests'
  end

  def ping
    @elasticsearch.ping
  end

  def index_body(test)
    {
        test_id: test.id,
        patient_name: test&.order&.encounter&.client&.person&.fullname,
        patient_name_soundex: "#{test&.order&.encounter&.client&.person&.first_name_soundex}#{test&.order&.encounter&.client&.person&.last_name_soundex}",
        first_name: test&.order&.encounter&.client&.person&.first_name,
        last_name: test&.order&.encounter&.client&.person&.last_name,
        first_name_soundex: test&.order&.encounter&.client&.person&.first_name_soundex,
        last_name_soundex: test&.order&.encounter&.client&.person&.last_name_soundex,
        accession_number: test&.order&.accession_number,
        tracking_number: test&.order&.tracking_number,
        test_name: test&.test_type&.name,
        location: test&.order&.encounter&.facility_section&.name,
        test_status: Status.where(id: test&.status_id).first&.name,
        order_status: Status.where(id: test&.order&.status_id).first&.name,
        test_time_created: test&.created_date
      }
  end

  def index_test(test)
      @elasticsearch.index(
        index: @index_name,
        id: test.id,
        body: index_body(test)
      )
      puts "Indexing record---> tracking_number: #{test&.order&.tracking_number}  Accession number: #{test&.accession_number} current date: #{test.created_date.to_date}"
  rescue StandardError => e
      puts e.message
  end

  def update_index
    params = { index: @index_name, size: 1, sort: 'test_id:desc' }
    begin
      @elasticsearch.search(params)['hits']['hits'][0]['sort'][0]
      es_test_id = 40_032
      tests = Test.where(id: (es_test_id + 1)...)
      Parallel.map(tests, in_processes: 4) do |test|
        @elasticsearch.create(
          index: @index_name,
          id: test&.id,
          body: index_body(test)
        )
        puts "Updating record---> tracking_number: #{test&.order&.tracking_number}"
      end
    rescue StandardError => e
      puts e.message
    end
  end

  def extract_first_and_last(name)
    parts = name.split
    first = parts.first
    last = parts.last
    { first_name: first, last_name: last }
  end

  def search(q, facility_sections)
    q_soundex = extract_first_and_last(q)
    base_query = {
      bool: {
        should: [
          {
            match: {
              patient_name_soundex: {
                query: "#{q_soundex[:first_name].soundex}#{q_soundex[:last_name].soundex}"
              }
            }
          },
          {
            match: {
              patient_name_soundex: {
                query: "#{q_soundex[:last_name].soundex}#{q_soundex[:first_name].soundex}"
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
    unless AppSetting.find_by(name: 'elasticsearch_enable_high_accuracy')&.value == 'true'
      base_query[:bool][:should] << {
        match: {
          patient_name: {
            query: q,
            fuzziness: 2
          }
        }
      }
    end
    params = {
      index: @index_name,
      from: 0,
      size: 10_000,
      body: {
        min_score: q.present? ? 0.5 : 0.0,
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
