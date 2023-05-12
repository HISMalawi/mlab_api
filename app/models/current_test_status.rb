# frozen_string_literal: true

# model for Current Test Status
class CurrentTestStatus < ApplicationRecord
  self.table_name  = 'current_test_status'
  self.primary_key = 'test_id'

  belongs_to :test, class_name: 'Test', foreign_key: 'test_id', primary_key: 'id'
end