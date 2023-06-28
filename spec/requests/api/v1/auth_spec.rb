#frozen_string_literal: true

require 'swagger_helper'

TAG_NAME = 'Authentication'
TAG_DESCRIPTION = 'Authenticating a user'

RSpec.describe 'api/v1/auth', type: :request do
  shared_examples 'authentication response' do
    response '200', 'Authentication successful' do
      schema type: 'object',
        properties: {
          token: { type: 'string' },
          expiry_time: { type: 'string' },
          user: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              username: { type: 'string' },
              first_name: { type: 'string' },
              middle_name: { type: 'string' },
              last_name: { type: 'string' },
              sex: { type: 'string' },
              is_active: { type: 'boolean' },
              date_of_birth: { type: 'string' },
              birth_date_estimated: { type: 'string' },
              voided: { type: 'integer' },
              voided_reason: { type: 'string' },
              roles: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    id: { type: 'integer' },
                    role_id: { type: 'integer' },
                    role_name: { type: 'string' }
                  }
                }
              },
              departments: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    id: { type: 'integer' },
                    name: { type: 'string' },
                    retired: { type: 'integer' },
                    retired_reason: { type: 'string' }
                  }
                }
              }
            }
          }
        }
      run_test!
    end

    response '401', 'UnAuthorized' do
      schema type: 'object',
        properties: {
          error: { type: 'string' }
        }
      run_test!
    end
  end

  path '/api/v1/auth/login' do
    post('Login to get jwt key') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      parameter name: :auth, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          password: { type: :string },
          department: { type: :string }
        },
        required: %w[username password department]
      }
      include_examples 'authentication response'
    end
  end

  path '/api/v1/auth/application_login' do
    post('application login auth') do
      tags TAG_NAME
      description TAG_DESCRIPTION
      consumes 'application/json'
      produces 'application/json'
      parameter name: :auth, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          password: { type: :string }
        },
        required: %w[username password]
      }
      include_examples 'authentication response'
    end
  end

  path '/api/v1/auth/refresh_token' do
    get('refresh_token auth') do
      tags TAG_NAME
      description 'Refresh token'
      security [bearerAuth: []]
      produces 'application/json'
      include_examples 'authentication response'
    end
  end
end
