class MohReport < ApplicationRecord
  self.table_name  = 'moh_report'
  self.primary_key = 'test_id'

  belongs_to :test, class_name: 'Test', foreign_key: 'test_id', primary_key: 'id'
end