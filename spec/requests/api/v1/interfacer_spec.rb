# frozen_string_literal: true

require 'swagger_helper'

TAG_NAME = 'Interfacer'
TAG_DESCRIPTION = 'Interfacer API Endpoints'

RSpec.describe 'api/v1/interfacer', type: :request do
  path '/api/v1/interfacer/fetch_results' do
    get('fetch_results interfacer') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :accession_number, in: :query, type: :string, description: 'accession_number'
      response(200, 'successful') do
        let(:accession_number) { '123' }
        schema type: :array, items: {
          type: :object,
          properties: {
            indicator_id: { type: :string },
            value: { type: :string },
            machine_name: { type: :string },
            indicator_name: { type: :string }
          }
        }

        run_test!
      end
    end
  end

  path '/api/v1/interfacer/result_available' do
    get('result_available interfacer') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :accession_number, in: :query, type: :string, description: 'accession_number'
      response(200, 'successful') do
        let(:accession_number) { '123' }
        schema type: :object, properties: { result_available: { type: :boolean } }
        run_test!
      end
    end
  end

  path '/api/v1/interfacer' do
    post('update interfacer') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'

      parameter name: :interfacer, in: :body, schema: {
        type: :object,
        properties: {
          accession_number: { type: :string },
          machine_name: { type: :string },
          measure_id: { type: :string },
          result: { type: :string },
          PHP_AUTH_USER: { type: :string },
          PHP_AUTH_PW: { type: :string }
        },
        required: %w[accession_number machine_name measure_id result]
      }
      response(200, 'successful') do
        let(:interfacer) do
          { accession_number: '123', machine_name: 'machine', measure_id: 'measure', result: 'result' }
        end
        schema type: :object, properties: { message: { type: :string } }
        run_test!
      end
    end
  end
end
