# frozen_string_literal: true

require 'swagger_helper'

TAG_NAME = 'Global'
TAG_DESCRIPTION = 'Manage site details'

RSpec.describe 'api/v1/global', type: :request do
  path '/api/v1/global' do
    get('Display site details') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      produces 'application/json'
      response(200, 'successful') do
        schema type: :object,
               properties: {
                id: { type: :integer },
                name: { type: :string },
                code: { type: :string },
                address: { type: :string },
                phone: { type: :string },
                created_date: { type: :string }
               }
        run_test!
      end
    end

    post('create site with details') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :global, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          code: { type: :string },
          address: { type: :string },
          phone: { type: :string }
        },
        required: ['name', 'code', 'address', 'phone']
      }
      response(200, 'successful') do
        schema type: :object,
               properties: {
                id: { type: :integer },
                name: { type: :string },
                code: { type: :string },
                address: { type: :string },
                phone: { type: :string },
                created_date: { type: :string }
              }
        run_test!
      end
    end
  end

  path '/api/v1/global/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    put('update site details') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :global, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          code: { type: :string },
          address: { type: :string },
          phone: { type: :string }
        },
        required: ['name', 'code', 'address', 'phone']
      }
      response(200, 'successful') do
        schema type: :object,
               properties: {
                id: { type: :integer },
                name: { type: :string },
                code: { type: :string },
                address: { type: :string },
                phone: { type: :string },
                created_date: { type: :string }
              }
        run_test!
      end
    end

    delete('delete site details') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      security [bearerAuth: []]
      produces 'application/json' 
      response(200, 'successful') do
        schema type: :object,
               properties: {
                message: { type: :string }
              }
        run_test!
      end
    end
  end
  path '/api/v1/global/current_api_tag' do
    get('Get Api Git Tag') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      produces 'application/json'
      response(200, 'successful') do
        schema type: :object,
               properties: {
                git_tag: { type: :string }
               }
        run_test!
      end
    end
  end
end
