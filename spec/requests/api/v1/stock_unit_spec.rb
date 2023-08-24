# frozen_string_literal: true

require 'swagger_helper'

TAG_NAME = 'Stock Unit'
TAG_DESCRIPTION = 'Manage stock units'

RSpec.describe 'api/v1/stock_units', type: :request do
  path '/api/v1/stock_units' do
    get('Display stock units details') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      security [bearerAuth: []]
      produces 'application/json'
      response(200, 'successful') do
        schema type: :object,
               properties: [{
                id: { type: :integer },
                name: { type: :string },
                created_date: { type: :string }
               }]
        run_test!
      end
    end

    post('create stock unit') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :stock_unit, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }
      response(200, 'successful') do
        schema type: :object,
               properties: {
                id: { type: :integer },
                name: { type: :string },
                created_date: { type: :string }
              }
        run_test!
      end
    end
  end

  path '/api/v1/stock_unit/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    put('update stock unit') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :stock_unit, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }
      response(200, 'successful') do
        schema type: :object,
               properties: {
                id: { type: :integer },
                name: { type: :string },
                created_date: { type: :string }
              }
        run_test!
      end
    end

    delete('delete stock unit') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :stock_unit, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string }
        },
        required: ['reason']
      }
      response(200, 'successful') do
        schema type: :object,
               properties: {
                message: { type: :string }
              }
        run_test!
      end
    end
  end
end
