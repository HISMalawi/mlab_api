# frozen_string_literal: true

# model for Current Order Status
class CurrentOrderStatus < ApplicationRecord
  self.table_name  = 'current_order_status'
  self.primary_key = 'order_id'

  belongs_to :order, class_name: 'Order', foreign_key: 'order_id', primary_key: 'id'
end